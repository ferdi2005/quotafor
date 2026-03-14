class InAppNotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.in_app_notifications.includes(:calendar_event).order(created_at: :desc)
  end

  def mark_as_read
    notification = current_user.in_app_notifications.find(params[:id])
    notification.update(read_at: Time.current)
    redirect_back fallback_location: in_app_notifications_path
  end
end
