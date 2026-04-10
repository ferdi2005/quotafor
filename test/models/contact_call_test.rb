require "test_helper"

class ContactCallTest < ActiveSupport::TestCase
  test "maps call types to calendar colors" do
    assert_equal "#198754", ContactCall.new(call_type: :first_visit).send(:call_type_color)
    assert_equal "#fd7e14", ContactCall.new(call_type: :second_visit).send(:call_type_color)
    assert_equal "#0d6efd", ContactCall.new(call_type: :assistance).send(:call_type_color)
  end

  test "creates a follow-up call and syncs the follow-up calendar event" do
    scheduled_for = Time.zone.local(2026, 4, 15, 14, 30, 0)

    call = ContactCall.create!(
      customer: customers(:one),
      user: users(:one),
      called_at: Time.zone.local(2026, 4, 14, 9, 0, 0),
      scheduled_for: scheduled_for,
      call_type: :second_visit,
      notes: "Verificare il portafoglio"
    )

    follow_up_call = call.follow_up_call

    assert_not_nil follow_up_call
    assert_equal 1, ContactCall.where(generated_from: call).count
    assert_equal scheduled_for, follow_up_call.called_at
    assert_equal "second_visit", follow_up_call.call_type
    assert_equal call, follow_up_call.generated_from

    assert_nil call.calendar_event

    assert_not_nil follow_up_call.calendar_event
    assert_equal scheduled_for, follow_up_call.calendar_event.starts_at
    assert_equal "#fd7e14", follow_up_call.calendar_event.color
    assert_equal "Telefonata Seconda visita - MyString MyString", follow_up_call.calendar_event.title
  end
end
