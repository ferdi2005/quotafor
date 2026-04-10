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
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )
    assert ra.valid?
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

  # ---- CalendarEvent generation ----

  test "creazione attività ricorrente attiva genera eventi futuri" do
    before = CalendarEvent.count
    RecurringActivity.create!(
      user: @user,
      topic: "Studio",
      weekday: :monday,
      periodicity: :weekly,
      starts_at: Time.current.change(hour: 9, min: 0),
      ends_at: Time.current.change(hour: 10, min: 0),
      active: true
    )
    assert CalendarEvent.count > before, "Doveva creare almeno un CalendarEvent"
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
