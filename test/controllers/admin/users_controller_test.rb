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
            email_notifications: "1"
          }
        }
      end

      assert_redirected_to admin_users_path
      assert_equal "Utente creato con successo.", flash[:notice]
    end

    test "update modifica utente" do
      sign_in @admin_user

      patch admin_user_path(@normal_user), params: {
        user: {
          first_name: "Laura Aggiornata",
          admin: "0",
          email_notifications: "0",
          password: "",
          password_confirmation: ""
        }
      }

      assert_redirected_to admin_users_path
      assert_equal "Utente aggiornato con successo.", flash[:notice]
      assert_equal "Laura Aggiornata", @normal_user.reload.first_name
      assert_not @normal_user.email_notifications
    end

    test "update blocca demozione dell'ultimo admin" do
      sign_in @admin_user

      patch admin_user_path(@admin_user), params: {
        user: {
          admin: "0"
        }
      }

      assert_redirected_to admin_users_path
      assert_equal "Non puoi rimuovere i privilegi all'ultimo admin.", flash[:alert]
      assert @admin_user.reload.admin?
    end

    test "destroy blocca utente con dati associati" do
      sign_in @admin_user

      assert_no_difference "User.count" do
        delete admin_user_path(@normal_user)
      end

      assert_redirected_to admin_users_path
      assert_equal "Impossibile eliminare un utente con dati associati.", flash[:alert]
    end

    test "destroy elimina utente senza dati associati" do
      sign_in @admin_user

      disposable_user = User.create!(
        email: "disposable@example.com",
        password: "password123",
        password_confirmation: "password123",
        time_zone: "Europe/Rome",
        admin: false
      )

      assert_difference "User.count", -1 do
        delete admin_user_path(disposable_user)
      end

      assert_redirected_to admin_users_path
      assert_equal "Utente eliminato con successo.", flash[:notice]
    end

    test "destroy blocca eliminazione ultimo admin" do
      sign_in @admin_user

      assert_no_difference "User.count" do
        delete admin_user_path(@admin_user)
      end

      assert_redirected_to admin_users_path
      assert_equal "Non puoi eliminare l'ultimo admin.", flash[:alert]
    end
  end
end
