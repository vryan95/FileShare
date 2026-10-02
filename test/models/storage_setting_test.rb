require "test_helper"

class StorageSettingTest < ActiveSupport::TestCase
  FakeAzureClient = Struct.new(:container_exists, :error) do
    def container_exist?
      raise error if error
      container_exists
    end
  end

  def with_env(values)
    original = values.keys.index_with { |key| ENV[key] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each { |key, value| ENV[key] = value }
  end

  def azure_setting(client: FakeAzureClient.new(true, nil))
    StorageSetting.new(service: "azure", azure_storage_account_name: "account", azure_storage_access_key: "key", azure_container: "fileshare").tap do |setting|
      setting.define_singleton_method(:azure_client) { client }
    end
  end

  test "new blobs use the configured service when nothing is saved" do
    assert_nil StorageSetting.default_service_name
    assert_equal "test", ActiveStorage::Blob.new.service_name
  end

  test "new blobs use the saved service" do
    StorageSetting.create!(service: "local")

    assert_equal "local", ActiveStorage::Blob.new.service_name
  end

  test "existing blobs keep their service" do
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new("hello"), filename: "hello.txt")
    StorageSetting.create!(service: "local")

    assert_equal "test", ActiveStorage::Blob.find(blob.id).service_name
  end

  test "rejects unknown services" do
    assert_not StorageSetting.new(service: "dropbox").valid?
  end

  test "requires azure details when azure is selected" do
    setting = StorageSetting.new(service: "azure")

    assert_not setting.valid?
    assert_includes setting.errors[:azure_storage_account_name], "can't be blank"
    assert_includes setting.errors[:azure_storage_access_key], "can't be blank"
    assert_includes setting.errors[:azure_container], "can't be blank"
  end

  test "accepts a reachable azure container" do
    assert azure_setting.valid?
  end

  test "rejects a missing azure container" do
    setting = azure_setting(client: FakeAzureClient.new(false, nil))

    assert_not setting.valid?
    assert_includes setting.errors[:azure_container], "doesn't exist in this storage account"
  end

  test "rejects azure details that cannot connect" do
    setting = azure_setting(client: FakeAzureClient.new(nil, AzureBlob::Http::Error.new))

    assert_not setting.valid?
    assert_includes setting.errors[:base], "Could not connect to Azure Blob Storage. Check the account name and access key."
  end

  test "azure config prefers saved settings over env vars" do
    StorageSetting.insert!({ service: "local", azure_storage_account_name: "saved", azure_storage_access_key: "saved-key", azure_container: "saved-container" })

    with_env("AZ_STORAGE_ACCOUNT" => "env", "AZ_STORAGE_ACCESS_KEY" => "env-key") do
      assert_equal({ storage_account_name: "saved", storage_access_key: "saved-key", container: "saved-container" }, StorageSetting.azure_config)
    end
  end

  test "azure config falls back to env vars" do
    with_env("AZ_STORAGE_ACCOUNT" => "env", "AZ_STORAGE_ACCESS_KEY" => "env-key", "AZ_STORAGE_CONTAINER" => nil) do
      assert_equal({ storage_account_name: "env", storage_access_key: "env-key", container: "fileshare" }, StorageSetting.azure_config)
    end
  end

  test "azure service uses the current settings" do
    service = ActiveStorage::Blob.services.fetch(:azure)

    with_env("AZ_STORAGE_ACCOUNT" => nil, "AZ_STORAGE_ACCESS_KEY" => nil) do
      assert_raises(ActiveStorage::Error) { service.send(:azure_service) }

      StorageSetting.insert!({ service: "local", azure_storage_account_name: "first", azure_storage_access_key: "a2V5", azure_container: "files" })
      first = service.send(:azure_service)
      assert_kind_of ActiveStorage::Service::AzureBlobService, first
      assert_equal :azure, first.name
      assert_same first, service.send(:azure_service)

      StorageSetting.update_all(azure_container: "other")
      assert_equal "other", service.send(:azure_service).container
    end
  end
end
