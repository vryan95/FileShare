class ThemePreferencesController < ApplicationController
  before_action :require_login

  def update
    selected_theme = params[:theme]

    unless User::THEMES.include?(selected_theme)
      redirect_back fallback_location: root_path, alert: t("general.theme.invalid")
      return
    end

    current_user.update!(theme_preference: selected_theme)
    redirect_back fallback_location: root_path, notice: t("general.theme.updated")
  end
end
