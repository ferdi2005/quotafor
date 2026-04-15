class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_time_zone

  protected

  def configure_permitted_parameters
    added_attrs = [
      :first_name,
      :last_name,
      :phone,
      :time_zone,
      :email_notifications,
      :in_app_notifications
    ]

    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  def switch_time_zone(&)
    zone = current_user&.time_zone.presence || "Europe/Rome"
    Time.use_zone(zone, &)
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to dashboard_path, alert: "Accesso riservato agli amministratori."
  end
end
