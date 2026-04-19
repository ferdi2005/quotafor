require "test_helper"

class CalendarEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "GET index defaults to future events in the current month" do
    past_date = Date.current - 1.day
    future_date = Date.current + 2.days

    CalendarEvent.create!(
      user: @user,
      customer: Customer.create!(
        user: @user,
        first_name: "Passato",
        last_name: "Evento",
        relationship_started_on: Date.current,
        customer_type: :existing_customer
      ),
      title: "Evento passato",
      description: "d",
      starts_at: Time.zone.local(past_date.year, past_date.month, past_date.day, 10, 0, 0),
      ends_at: Time.zone.local(past_date.year, past_date.month, past_date.day, 11, 0, 0),
      category: :customer_appointment,
      color: "#198754"
    )

    CalendarEvent.create!(
      user: @user,
      customer: Customer.create!(
        user: @user,
        first_name: "Futuro",
        last_name: "Evento",
        relationship_started_on: Date.current,
        customer_type: :existing_customer
      ),
      title: "Evento futuro",
      description: "d",
      starts_at: Time.zone.local(future_date.year, future_date.month, future_date.day, 10, 0, 0),
      ends_at: Time.zone.local(future_date.year, future_date.month, future_date.day, 11, 0, 0),
      category: :customer_appointment,
      color: "#198754"
    )

    get calendar_events_path

    assert_response :success
    assert_includes response.body, "Evento futuro"
    assert_not_includes response.body, "Evento passato"
  end

  test "GET index filters appointments by appointment_type" do
    customer_follow_up = Customer.create!(
      user: @user,
      first_name: "Follow",
      last_name: "Up",
      relationship_started_on: Date.current,
      customer_type: :existing_customer
    )
    customer_first_meeting = Customer.create!(
      user: @user,
      first_name: "First",
      last_name: "Meeting",
      relationship_started_on: Date.current,
      customer_type: :existing_customer
    )
    event_day = Date.current + 2.days

    follow_up = Appointment.create!(
      user: @user,
      customer: customer_follow_up,
      starts_at: Time.zone.local(event_day.year, event_day.month, event_day.day, 9, 0, 0),
      ends_at: Time.zone.local(event_day.year, event_day.month, event_day.day, 10, 0, 0),
      appointment_type: :follow_up,
      status: :scheduled
    )
    first_meeting = Appointment.create!(
      user: @user,
      customer: customer_first_meeting,
      starts_at: Time.zone.local(event_day.year, event_day.month, event_day.day, 11, 0, 0),
      ends_at: Time.zone.local(event_day.year, event_day.month, event_day.day, 12, 0, 0),
      appointment_type: :first_meeting,
      status: :scheduled
    )

    get calendar_events_path(kind: "appointments", appointment_type: "follow_up")

    assert_response :success
    assert_includes response.body, follow_up.customer.full_name
    assert_not_includes response.body, first_meeting.customer.full_name
  end
end
