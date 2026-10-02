class StorageSettingsController < ApplicationController
  before_action :require_login, :require_admin
  before_action :set_storage_setting

  def edit
  end

  def update
    attributes = storage_setting_params
    attributes.delete(:azure_storage_access_key) if attributes[:azure_storage_access_key].blank? && @storage_setting.persisted?

    if @storage_setting.update(attributes)
      redirect_to edit_storage_setting_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_storage_setting
    @storage_setting = StorageSetting.first || StorageSetting.current
  end

  def storage_setting_params
    params.require(:storage_setting).permit(:service, :azure_storage_account_name, :azure_storage_access_key, :azure_container)
  end
end
