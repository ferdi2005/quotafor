require "test_helper"

class InAppNotificationTest < ActiveSupport::TestCase
  setup do
    @user  = users(:one)
    @event = calendar_events(:one)
  end

  test "valid notification is created successfully" do
    notif = InAppNotification.new(
      user: @user,
      calendar_event: @event,
      title: "Promemoria",
      body: "Appuntamento domani",
      notification_type: :generic
    )
    assert notif.valid?
  end

  test "requires title" do
    notif = InAppNotification.new(
      user: @user, calendar_event: @event,
      body: "Corpo", notification_type: :generic
    )
    assert_not notif.valid?
    assert notif.errors[:title].present?
  end

  test "requires body" do
    notif = InAppNotification.new(
      user: @user, calendar_event: @event,
      title: "Titolo", notification_type: :generic
    )
    assert_not notif.valid?
    assert notif.errors[:body].present?
  end

  test "supports reminder_day_before notification type" do
    notif = InAppNotification.new(
      user: @user, calendar_event: @event,
      title: "Titolo", body: "Corpo",
      notification_type: :reminder_day_before
    )
    assert notif.valid?
    assert notif.reminder_day_before?
  end

  test "unread scope excludes notifications with read_at set" do
    read = in_app_notifications(:one)    # has read_at set in fixture
    unread = in_app_notifications(:unread)
    assert_includes InAppNotification.unread, unread
    assert_not_includes InAppNotification.unread, read
  end
end
