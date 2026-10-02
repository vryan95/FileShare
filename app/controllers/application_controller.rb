class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_setup

  helper_method :current_user, :logged_in?, :theme_preference, :next_theme_preference

  private

  def require_setup
    redirect_to new_setup_path unless User.exists?
  end

  def start_session_for(user)
    reset_session
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def theme_preference
    current_user&.theme_preference.presence_in(User::THEMES) || "light"
  end

  def next_theme_preference
    theme_preference == "dark" ? "light" : "dark"
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "You must be logged in to access this page."
    end
  end

  def require_admin
    redirect_to root_path, alert: t("general.admin_required") unless current_user&.admin?
  end
end
