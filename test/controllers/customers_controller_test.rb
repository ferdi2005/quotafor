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

  test "create assigns referred_by_customer when selected" do
    assert_difference "Customer.count", 1 do
      post customers_path, params: {
        customer: {
          first_name: "Referenziato",
          last_name: "Nuovo",
          relationship_started_on: Date.current,
          customer_type: "new_customer",
          referred_by_customer_id: @own_customer.id
        }
      }
    end

    assert_equal @own_customer, Customer.last.referred_by_customer
  end

  test "create saves nested investments with and without advisor" do
    assert_difference "Customer.count", 1 do
      assert_difference "Investment.count", 2 do
        post customers_path, params: {
          customer: {
            first_name: "Invest",
            last_name: "Cliente",
            relationship_started_on: Date.current,
            customer_type: "new_customer",
            investments_attributes: {
              "0" => {
                with_me: "false",
                product_name: "ETF Mondo",
                distributed_by: "Banca X",
                amount: "10000"
              },
              "1" => {
                with_me: "true",
                active: "1",
                product_name: "Fondo Pensione",
                distributed_by: "Rete Y",
                amount: "5000"
              }
            }
          }
        }
      end
    end

    customer = Customer.last
    assert_equal 2, customer.investments.count
    assert_equal 1, customer.investments_with_me.count
    assert_equal 1, customer.investments_with_others.count
  end

  test "create ignores blank nested investment rows" do
    assert_difference "Customer.count", 1 do
      assert_no_difference "Investment.count" do
        post customers_path, params: {
          customer: {
            first_name: "Senza",
            last_name: "Investimenti",
            relationship_started_on: Date.current,
            customer_type: "new_customer",
            investments_attributes: {
              "0" => { with_me: "false", active: "0" },
              "1" => { with_me: "true", active: "1" }
            }
          }
        }
      end
    end
  end

  test "create ignores referred_by_customer from another user" do
    assert_difference "Customer.count", 1 do
      post customers_path, params: {
        customer: {
          first_name: "Referenziato",
          last_name: "Sicuro",
          relationship_started_on: Date.current,
          customer_type: "new_customer",
          referred_by_customer_id: @other_customer.id
        }
      }
    end

    assert_nil Customer.last.referred_by_customer
  end

  test "create in privacy mode uses defaults for hidden fields" do
    original_privacy = ENV["PRIVACY"]
    ENV["PRIVACY"] = "true"

    begin
      assert_difference "Customer.count", 1 do
        post customers_path, params: {
          customer: {
            first_name: "Privacy",
            last_name: "Mode",
            phone: "123456789",
            email: "privacy@example.com"
          }
        }
      end

      created_customer = Customer.last
      assert_equal Date.current, created_customer.relationship_started_on
      assert_equal "new_customer", created_customer.customer_type
    ensure
      ENV["PRIVACY"] = original_privacy
    end
  end

  test "referrer_suggestions returns only current user customers" do
    own_extra_customer = Customer.create!(
      user: @user,
      first_name: "Mario",
      last_name: "Rossi",
      relationship_started_on: Date.current,
      customer_type: :new_customer
    )

    get referrer_suggestions_customers_path, params: { q: "mario" }, as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    result_ids = payload.fetch("results").map { |entry| entry.fetch("id") }

    assert_includes result_ids, own_extra_customer.id
    assert_not_includes result_ids, @other_customer.id
  end

  test "referrer_suggestions excludes selected customer id" do
    get referrer_suggestions_customers_path,
        params: { q: @own_customer.first_name, exclude_customer_id: @own_customer.id },
        as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    result_ids = payload.fetch("results").map { |entry| entry.fetch("id") }

    assert_not_includes result_ids, @own_customer.id
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
