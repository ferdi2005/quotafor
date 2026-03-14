require "test_helper"

class InAppNotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user         = users(:one)
    @notification = in_app_notifications(:unread)
    sign_in @user
  end

  test "index requires authentication" do
    sign_out @user
    get in_app_notifications_path
    assert_redirected_to new_user_session_path
  end

  test "index returns success" do
    get in_app_notifications_path
    assert_response :success
  end

  test "mark_as_read sets read_at on own notification" do
    assert_nil @notification.read_at
    patch mark_as_read_in_app_notification_path(@notification)
    assert_not_nil @notification.reload.read_at
  end

  test "mark_as_read redirects back to notifications" do
    patch mark_as_read_in_app_notification_path(@notification)
    assert_redirected_to in_app_notifications_path
  end

  test "mark_as_read requires authentication" do
    sign_out @user
    patch mark_as_read_in_app_notification_path(@notification)
    assert_redirected_to new_user_session_path
  end

  test "mark_as_read on other user's notification raises 404" do
    other_notification = in_app_notifications(:two)
    patch mark_as_read_in_app_notification_path(other_notification)
    assert_response :not_found
  end
end
