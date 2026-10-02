class EntraSettingsController < ApplicationController
  before_action :require_login, :require_admin
  before_action :set_entra_setting

  def edit
  end

  def update
    attributes = entra_setting_params
    attributes.delete(:client_secret) if attributes[:client_secret].blank? && @entra_setting.persisted?

    if @entra_setting.update(attributes)
      redirect_to edit_entra_setting_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_entra_setting
    @entra_setting = EntraSetting.first_or_initialize
  end

  def entra_setting_params
    params.require(:entra_setting).permit(:client_id, :client_secret, :tenant_id)
  end
end
