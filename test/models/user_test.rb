require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "regenerate_feed_token! changes the calendar_feed_token" do
    old_token = @user.calendar_feed_token
    @user.regenerate_feed_token!
    assert_not_equal old_token, @user.reload.calendar_feed_token
  end

  test "regenerate_feed_token! sets feed_token_generated_at" do
    freeze_time do
      @user.regenerate_feed_token!
      assert_in_delta Time.current.to_i, @user.reload.feed_token_generated_at.to_i, 1
    end
  end

  test "calendar_feed_token is unique" do
    duplicate = User.new(
      email: "unique@example.com",
      password: "password123",
      time_zone: "Europe/Rome",
      calendar_feed_token: @user.calendar_feed_token
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:calendar_feed_token].present?
  end

  test "time_zone is required" do
    @user.time_zone = nil
    assert_not @user.valid?
    assert @user.errors[:time_zone].present?
  end

  test "refresh_rfa_expected! sums objective resource deltas" do
    customer = customers(:one)

    customer.customer_objectives.create!(
      title: "Obiettivo A",
      active: true,
      invested_resources: 120,
      diminished_resources: 20
    )

    customer.customer_objectives.create!(
      title: "Obiettivo B",
      active: true,
      invested_resources: 15,
      diminished_resources: 10
    )

    @user.refresh_rfa_expected!

    assert_equal BigDecimal("105.0"), @user.reload.rfa_expected
  end
end
