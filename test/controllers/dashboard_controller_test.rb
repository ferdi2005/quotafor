require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "index requires authentication" do
    sign_out @user
    get dashboard_path
    assert_redirected_to new_user_session_path
  end

  test "index returns all customers for current user" do
    get dashboard_path
    assert_response :success
  end

  test "index filters customers by full_name" do
    get dashboard_path, params: { filters: { full_name: "MyString" } }
    assert_response :success
    assert_includes response.body, "MyString"
  end

  test "index filters customers by customer_type" do
    get dashboard_path, params: { filters: { customer_type: "existing_customer" } }
    assert_response :success
  end

  test "index filters by combined full_name and customer_type" do
    get dashboard_path, params: { filters: { full_name: "MyString", customer_type: "existing_customer" } }
    assert_response :success
  end

  test "index ignores unknown customer_type filter" do
    get dashboard_path, params: { filters: { customer_type: "nonexistent_type" } }
    assert_response :success
  end
end
