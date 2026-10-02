# New uploads go to the service chosen on the storage settings page (see StorageSetting).
ActiveSupport.on_load(:active_storage_blob) do
  singleton_class.prepend StorageSetting::DefaultBlobService
end
