module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @users = User.ordered
      @user = User.new(time_zone: "Europe/Rome")
    end

    def new
      @user = User.new(time_zone: "Europe/Rome")
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: "Utente creato con successo."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :email,
        :password,
        :password_confirmation,
        :first_name,
        :last_name,
        :phone,
        :time_zone,
        :email_notifications,
        :in_app_notifications,
        :admin
      )
    end
  end
end
