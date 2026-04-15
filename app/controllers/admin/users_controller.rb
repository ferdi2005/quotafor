module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_user, only: %i[edit update destroy]

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

    def edit
    end

    def update
      if demoting_last_admin?
        redirect_to admin_users_path, alert: "Non puoi rimuovere i privilegi all'ultimo admin."
        return
      end

      attributes = user_params.to_h
      if attributes["password"].blank? && attributes["password_confirmation"].blank?
        attributes.except!("password", "password_confirmation")
      end

      if @user.update(attributes)
        redirect_to admin_users_path, notice: "Utente aggiornato con successo."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if deleting_last_admin?
        redirect_to admin_users_path, alert: "Non puoi eliminare l'ultimo admin."
        return
      end

      if has_associated_data?
        redirect_to admin_users_path, alert: "Impossibile eliminare un utente con dati associati."
        return
      end

      @user.destroy
      redirect_to admin_users_path, notice: "Utente eliminato con successo."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def demoting_last_admin?
      return false unless @user.admin?

      desired_admin_value = ActiveModel::Type::Boolean.new.cast(user_params[:admin])
      !desired_admin_value && User.where(admin: true).where.not(id: @user.id).none?
    end

    def deleting_last_admin?
      @user.admin? && User.where(admin: true).where.not(id: @user.id).none?
    end

    def has_associated_data?
      @user.customers.exists? ||
        @user.customer_objectives.exists? ||
        @user.appointments.exists? ||
        @user.contact_calls.exists? ||
        @user.recurring_activities.exists? ||
        @user.calendar_events.exists? ||
        @user.in_app_notifications.exists?
    end

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
        :admin
      )
    end
  end
end
