require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user        = users(:one)
    @other_user  = users(:two)
    @own_customer  = customers(:one)
    @other_customer = customers(:two)
    sign_in @user
  end

  test "show own customer succeeds" do
    get customer_path(@own_customer)
    assert_response :success
  end

  test "show other user's customer raises 404" do
    get customer_path(@other_customer)
    assert_response :not_found
  end

  test "create assigns customer to current user" do
    assert_difference "Customer.count", 1 do
      post customers_path, params: {
        customer: {
          first_name: "Test",
          last_name: "Utente",
          relationship_started_on: Date.current,
          customer_type: "new_customer"
        }
      }
    end
    assert_equal @user, Customer.last.user
  end

  test "destroy removes own customer" do
    assert_difference "Customer.count", -1 do
      delete customer_path(@own_customer)
    end
    assert_redirected_to dashboard_path
  end

  test "destroy other user's customer raises 404" do
    assert_difference "Customer.count", 0 do
      delete customer_path(@other_customer)
    end
    assert_response :not_found
  end
end
