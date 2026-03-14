require "test_helper"

class DeviseSessionsTest < ActionDispatch::IntegrationTest
  test "login con credenziali valide redirect a dashboard" do
    post user_session_path, params: {
      user: { email: users(:one).email, password: "password123" }
    }
    assert_redirected_to root_path
  end

  test "login con credenziali errate rimane su login con flash errore" do
    post user_session_path, params: {
      user: { email: users(:one).email, password: "wrongpassword" }
    }
    assert_response :unprocessable_entity
    assert_select "div.alert, p.alert, [data-flash]", minimum: 0
    assert_not flash[:notice].present?
  end

  test "logout redirect a login" do
    sign_in users(:one)
    delete destroy_user_session_path
    assert_response :redirect
  end

  test "accesso a risorsa protetta senza login redirect a login" do
    get recurring_activities_path
    assert_redirected_to new_user_session_path
  end
end
