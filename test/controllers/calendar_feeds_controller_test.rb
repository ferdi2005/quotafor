require "test_helper"

class CalendarFeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "GET feed with valid token returns ICS content" do
    get calendar_feed_path(token: @user.calendar_feed_token, format: :ics)
    assert_response :success
    assert_match "text/calendar", response.content_type
    assert_includes response.body, "BEGIN:VCALENDAR"
    assert_includes response.body, "END:VCALENDAR"
    assert_equal 'inline; filename="quotafor-calendar.ics"', response.headers["Content-Disposition"]
  end

  test "GET feed with valid token includes user email in cal name" do
    get calendar_feed_path(token: @user.calendar_feed_token, format: :ics)
    assert_response :success
    assert_includes response.body, @user.email
    assert_includes response.body, "METHOD:PUBLISH"
    assert_includes response.body, "NAME:QuotaFor - #{@user.email}"
    assert_includes response.body, "REFRESH-INTERVAL;VALUE=DURATION:P1D"
    assert_includes response.body, "X-PUBLISHED-TTL:P1D"
    assert_match(/UID:calendar-event-\d+@www\.example\.com/, response.body)
    assert_includes response.body, "STATUS:CONFIRMED"
  end

  test "GET feed with invalid token returns 404" do
    get calendar_feed_path(token: "invalid-nonexistent-token", format: :ics)
    assert_response :not_found
  end

  test "POST regenerate_token requires authentication" do
    post calendar_regenerate_token_path
    assert_redirected_to new_user_session_path
  end

  test "POST regenerate_token updates calendar_feed_token" do
    sign_in @user
    old_token = @user.calendar_feed_token
    post calendar_regenerate_token_path
    assert_not_equal old_token, @user.reload.calendar_feed_token
    assert_redirected_to calendar_events_path
  end
end
