require "test_helper"

class CalendarFeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "GET feed with valid token returns ICS content" do
    get calendar_feed_path(token: @user.calendar_feed_token, format: :ics)
    assert_response :success
    assert_match "text/calendar", response.content_type
    assert_match "charset=utf-8", response.content_type
    assert_includes response.body, "BEGIN:VCALENDAR"
    assert_includes response.body, "END:VCALENDAR"
    assert_equal 'inline; filename="quotafor-calendar.ics"', response.headers["Content-Disposition"]
    assert_equal "text/calendar; charset=utf-8; method=PUBLISH", response.headers["Content-Type"]
  end

  test "GET feed with valid token includes user email in cal name" do
    get calendar_feed_path(token: @user.calendar_feed_token, format: :ics)
    assert_response :success
    assert_includes response.body, @user.email
    assert_includes response.body, "METHOD:PUBLISH"
    assert_includes response.body, "NAME:QuotaFor - #{@user.email}"
    assert_includes response.body, "X-WR-CALNAME:QuotaFor - #{@user.email}"
    assert_includes response.body, "X-WR-TIMEZONE:Europe/Rome"
    assert_includes response.body, "REFRESH-INTERVAL;VALUE=DURATION:P1D"
    assert_includes response.body, "X-PUBLISHED-TTL:P1D"
    assert_match(/UID:calendar-event-\d+@www\.example\.com/, response.body)
    assert_includes response.body, "STATUS:CONFIRMED"
    assert_includes response.body, "BEGIN:VTIMEZONE"
    assert_includes response.body, "TZID:Europe/Rome"
    assert_match(/DTSTART;TZID=Europe\/Rome:/, response.body)
  end

  test "GET feed includes at least one RFC 5545 calendar component" do
    get calendar_feed_path(token: @user.calendar_feed_token, format: :ics)
    assert_response :success

    # RFC 5545 3.6: VCALENDAR must contain at least one calendar component.
    assert_match(/BEGIN:(VEVENT|VTODO|VJOURNAL|VFREEBUSY|VTIMEZONE)/, response.body)
  end

  test "GET feed for user without events still includes calendar component" do
    user_without_events = User.create!(
      email: "calendar-empty@example.com",
      password: "password123",
      password_confirmation: "password123",
      time_zone: "Europe/Rome"
    )

    get calendar_feed_path(token: user_without_events.calendar_feed_token, format: :ics)
    assert_response :success

    assert_includes response.body, "BEGIN:VCALENDAR"
    assert_includes response.body, "BEGIN:VTIMEZONE"
    assert_includes response.body, "END:VTIMEZONE"
    assert_includes response.body, "END:VCALENDAR"
    assert_match(/BEGIN:(VEVENT|VTODO|VJOURNAL|VFREEBUSY|VTIMEZONE)/, response.body)
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
