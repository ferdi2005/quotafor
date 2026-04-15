require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin_user = users(:one)
      @normal_user = users(:two)
    end

    test "index richiede autenticazione" do
      get admin_users_path
      assert_redirected_to new_user_session_path
    end

    test "index nega accesso a utente non admin" do
      sign_in @normal_user

      get admin_users_path

      assert_redirected_to dashboard_path
      assert_equal "Accesso riservato agli amministratori.", flash[:alert]
    end

    test "index disponibile per admin" do
      sign_in @admin_user

      get admin_users_path

      assert_response :success
      assert_includes response.body, "Gestione utenti"
      assert_includes response.body, @normal_user.email
    end

    test "new disponibile per admin" do
      sign_in @admin_user

      get new_admin_user_path

      assert_response :success
      assert_includes response.body, "Nuovo utente"
    end

    test "create crea nuovo utente" do
      sign_in @admin_user

      assert_difference "User.count", 1 do
        post admin_users_path, params: {
          user: {
            first_name: "Nuovo",
            last_name: "Utente",
            email: "nuovo.utente@example.com",
            password: "password123",
            password_confirmation: "password123",
            time_zone: "Europe/Rome",
            admin: "0",
            email_notifications: "1",
            in_app_notifications: "1"
          }
        }
      end

      assert_redirected_to admin_users_path
      assert_equal "Utente creato con successo.", flash[:notice]
    end
  end
end
