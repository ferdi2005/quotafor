require "test_helper"

class CalendarEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "index exposes https subscription url" do
    sign_in @user

    get calendar_events_path

    assert_response :success
    assert_select "a[href=?]", calendar_feed_url(token: @user.calendar_feed_token, format: :ics), text: "Iscriviti con Calendario"
  end
end
