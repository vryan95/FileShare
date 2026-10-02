require "active_storage/service/azure_blob_service"

module ActiveStorage
  # Azure Blob Storage service whose account, key and container come from StorageSetting
  # (saved by an admin, or AZ_* env vars), so they can change without restarting the app.
  class Service::SettingsAzureBlobService < Service
    delegate :upload, :update_metadata, :download, :download_chunk, :compose, :delete, :delete_prefixed, :exist?,
      :url, :url_for_direct_upload, :headers_for_direct_upload, :public?, to: :azure_service

    private

    def azure_service
      config = StorageSetting.azure_config or raise ActiveStorage::Error, "Azure storage is not configured"

      if @azure_config != config
        @azure_service = Service::AzureBlobService.new(**config).tap { |service| service.name = name }
        @azure_config = config
      end

      @azure_service
    end
  end
end
