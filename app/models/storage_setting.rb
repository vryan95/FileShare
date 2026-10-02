# Where uploads are stored, chosen by an admin so installs (e.g. through ONCE) don't need environment variables.
# Each blob remembers its service, so switching only affects new uploads; existing files stay where they are.
class StorageSetting < ApplicationRecord
  SERVICES = %w[local azure].freeze

  validates :service, inclusion: { in: SERVICES }
  validates :azure_storage_account_name, :azure_storage_access_key, :azure_container, presence: true, if: :azure?
  validate :azure_container_must_be_reachable, if: -> { azure? && errors.none? && azure_settings_changed? }

  normalizes :azure_storage_account_name, :azure_storage_access_key, :azure_container, with: ->(value) { value.strip }

  # Used by the settings form: the saved settings, or the service the app booted with.
  def self.current
    first || new(service: Rails.configuration.active_storage.service.to_s.presence_in(SERVICES) || "local")
  end

  # The service for new uploads, or nil to use config.active_storage.service.
  def self.default_service_name
    first&.service
  end

  # Credentials for the "azure" service: saved settings, falling back to AZ_* env vars.
  def self.azure_config
    setting = first
    setting = nil unless setting&.azure_configured?
    setting&.azure_config || env_azure_config
  end

  def self.env_azure_config
    return if ENV["AZ_STORAGE_ACCOUNT"].blank? || ENV["AZ_STORAGE_ACCESS_KEY"].blank?

    { storage_account_name: ENV["AZ_STORAGE_ACCOUNT"], storage_access_key: ENV["AZ_STORAGE_ACCESS_KEY"], container: ENV.fetch("AZ_STORAGE_CONTAINER", "fileshare") }
  end

  def azure?
    service == "azure"
  end

  def azure_configured?
    [ azure_storage_account_name, azure_storage_access_key, azure_container ].all?(&:present?)
  end

  def azure_config
    { storage_account_name: azure_storage_account_name, storage_access_key: azure_storage_access_key, container: azure_container }
  end

  def azure_client
    AzureBlob::Client.new(account_name: azure_storage_account_name, access_key: azure_storage_access_key, container: azure_container)
  end

  # Makes ActiveStorage::Blob.service (the default for new blobs) follow the saved setting.
  module DefaultBlobService
    def service
      (name = StorageSetting.default_service_name) ? services.fetch(name) : super
    end
  end

  private

  def azure_settings_changed?
    new_record? || will_save_change_to_service? ||
      will_save_change_to_azure_storage_account_name? || will_save_change_to_azure_storage_access_key? || will_save_change_to_azure_container?
  end

  def azure_container_must_be_reachable
    errors.add(:azure_container, :not_found) unless azure_client.container_exist?
  rescue StandardError => error
    Rails.logger.warn("Azure storage check failed: #{error.class}: #{error.message}")
    errors.add(:base, :azure_unreachable)
  end
end
