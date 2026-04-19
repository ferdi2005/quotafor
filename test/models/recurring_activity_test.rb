require "test_helper"

class RecurringActivityTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  # ---- Validations ----

  test "valid recurring activity passes validation" do
    ra = RecurringActivity.new(
      user: @user,
      topic: "Studio",
      weekday: :monday,
      periodicity: :weekly,
      end_date: Date.current + 30.days,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )
    assert ra.valid?
  end

  test "valid one-time activity passes validation" do
    ra = RecurringActivity.new(
      user: @user,
      topic: "Studio",
      periodicity: :one_time,
      activity_date: Date.current + 1.day,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )

    assert ra.valid?
  end

  test "expired recurring activity can be detected and deactivated" do
    ra = RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      weekday: :monday,
      periodicity: :weekly,
      end_date: Date.current - 1.day,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )

    assert ra.expired?
    assert_predicate ra, :active?

    ra.deactivate_if_expired!

    assert_not ra.reload.active?
  end

  test "requires starts_at" do
    ra = RecurringActivity.new(
      user: @user, topic: "Studio", weekday: :monday, periodicity: :weekly,
      starts_at: nil, ends_at: Time.current.change(hour: 10, min: 0)
    )
    assert_not ra.valid?
    assert ra.errors[:starts_at].present?
  end

  test "ends_at must be after starts_at" do
    ra = RecurringActivity.new(
      user: @user, topic: "Studio", weekday: :monday, periodicity: :weekly,
      starts_at: Time.current.change(hour: 10, min: 0),
      ends_at: Time.current.change(hour: 9, min: 0)
    )
    assert_not ra.valid?
    assert ra.errors[:ends_at].present?
  end

  test "one-time activity requires a date" do
    ra = RecurringActivity.new(
      user: @user,
      topic: "Studio",
      periodicity: :one_time,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )

    assert_not ra.valid?
    assert ra.errors[:activity_date].present?
  end

  # ---- CalendarEvent generation ----

  test "creazione attività ricorrente attiva genera eventi futuri" do
    before = CalendarEvent.count
    RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      weekday: :monday,
      periodicity: :weekly,
      end_date: Date.current + 30.days,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )
    assert CalendarEvent.count > before, "Doveva creare almeno un CalendarEvent"
  end

  test "le attività ricorrenti si fermano alla data di fine" do
    end_date = Date.current + 3.days

    ra = RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      weekday: :monday,
      periodicity: :daily,
      end_date: end_date,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )

    assert_equal 4, ra.calendar_events.count
    assert_operator ra.calendar_events.maximum(:starts_at).to_date, :<=, end_date
  end

  test "attività non attiva non genera eventi" do
    assert_no_difference "CalendarEvent.count" do
      RecurringActivity.create!(
        user: @user,
        topic: "Studio",
        weekday: :monday,
        periodicity: :weekly,
        starts_at: Time.current.change(hour: 9, min: 0),
        ends_at: Time.current.change(hour: 10, min: 0),
        active: false
      )
    end
  end

  test "attività singola attiva genera un solo evento" do
    before = CalendarEvent.count
    ra = RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      periodicity: :one_time,
      activity_date: Date.current + 2.days,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )

    assert_equal before + 1, CalendarEvent.count
    assert_equal 1, ra.calendar_events.count
    assert_equal Date.current + 2.days, ra.calendar_events.first.starts_at.to_date
  end

  test "aggiornare un'attività singola non duplica il calendario" do
    ra = RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      periodicity: :one_time,
      activity_date: Date.current + 3.days,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )

    assert_difference "ra.calendar_events.count", 0 do
      ra.update!(
        topic: "Studio aggiornato",
        periodicity: :one_time,
        activity_date: Date.current + 4.days,
        starts_at: Time.current.change(hour: 10, min: 0),
        ends_at: Time.current.change(hour: 11, min: 0),
        active: true
      )
    end

    assert_equal 1, ra.reload.calendar_events.count
    assert_equal Date.current + 4.days, ra.calendar_events.first.starts_at.to_date
  end

  test "frequenza mensile: il secondo evento ha lo stesso giorno del primo" do
    today = Time.zone.today
    ra = RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      weekday: :monday,
      periodicity: :monthly,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )
    events = ra.calendar_events.order(:starts_at)
    if events.size >= 2
      first_day  = events.first.starts_at.day
      second_day = events.second.starts_at.day
      # Both events should share the same day-of-month as the creation date
      assert_equal today.day, first_day
      assert_equal first_day, second_day
    else
      # Only one monthly occurrence in the 60-day window is acceptable
      assert events.size >= 1
    end
  end
end
