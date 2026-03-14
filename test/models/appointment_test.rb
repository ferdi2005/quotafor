require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user     = users(:one)
    @customer = customers(:one)
  end

  # ---- Validations ----

  test "valid appointment passes validation" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
      appointment_type: :first_meeting, status: :scheduled
    )
    assert appt.valid?
  end

  test "requires starts_at" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      ends_at: 2.hours.from_now,
      appointment_type: :first_meeting, status: :scheduled
    )
    assert_not appt.valid?
    assert appt.errors[:starts_at].present?
  end

  test "ends_at must be after starts_at" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: 2.hours.from_now, ends_at: 1.hour.from_now,
      appointment_type: :first_meeting, status: :scheduled
    )
    assert_not appt.valid?
    assert appt.errors[:ends_at].present?
  end

  test "ends_at equal to starts_at is invalid" do
    t = 1.hour.from_now
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: t, ends_at: t,
      appointment_type: :first_meeting, status: :scheduled
    )
    assert_not appt.valid?
    assert appt.errors[:ends_at].present?
  end

  test "negative_reason required when outcome is negative" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
      appointment_type: :first_meeting, status: :completed,
      outcome: :negative, negative_reason: nil
    )
    assert_not appt.valid?
    assert appt.errors[:negative_reason].present?
  end

  test "negative_reason not required when outcome is positive" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
      appointment_type: :first_meeting, status: :completed,
      outcome: :positive, visit_feedback: "Ottimo colloquio", presentation_notes: "Presentato portafoglio"
    )
    assert appt.valid?
  end

  test "visit_feedback required when outcome is positive" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
      appointment_type: :follow_up, status: :completed,
      outcome: :positive, visit_feedback: nil
    )
    assert_not appt.valid?
    assert appt.errors[:visit_feedback].present?
  end

  test "presentation_notes required for first_meeting when outcome is set" do
    appt = Appointment.new(
      user: @user, customer: @customer,
      starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
      appointment_type: :first_meeting, status: :completed,
      outcome: :negative, negative_reason: "Cliente non interessato", presentation_notes: nil
    )
    assert_not appt.valid?
    assert appt.errors[:presentation_notes].present?
  end

  # ---- Callbacks ----

  test "sync_calendar_event creates a CalendarEvent when appointment is created" do
    assert_difference "CalendarEvent.count", 1 do
      Appointment.create!(
        user: @user, customer: @customer,
        starts_at: 1.hour.from_now, ends_at: 2.hours.from_now,
        appointment_type: :first_meeting, status: :scheduled
      )
    end
  end

  test "schedule_day_before_reminder enqueues job for future appointment" do
    assert_enqueued_with(job: AppointmentDayBeforeReminderJob) do
      Appointment.create!(
        user: @user, customer: @customer,
        starts_at: 3.days.from_now, ends_at: 3.days.from_now + 1.hour,
        appointment_type: :first_meeting, status: :scheduled
      )
    end
  end

  test "schedule_day_before_reminder does not enqueue job when starts_at is in the past" do
    assert_no_enqueued_jobs(only: AppointmentDayBeforeReminderJob) do
      Appointment.create!(
        user: @user, customer: @customer,
        starts_at: 3.days.ago, ends_at: 3.days.ago + 1.hour,
        appointment_type: :first_meeting, status: :completed
      )
    end
  end
end
