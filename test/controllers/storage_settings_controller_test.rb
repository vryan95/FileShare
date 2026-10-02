require "test_helper"

class StorageSettingsControllerTest < ActionDispatch::IntegrationTest
  def sign_in(admin:)
    user = User.create!(name: "User", email: "storage-user@example.com", password: "correct horse battery", admin: admin)
    post login_url, params: { email: user.email, password: "correct horse battery" }
  end

  test "requires login" do
    get edit_storage_setting_url
    assert_redirected_to login_url
  end

  test "requires an admin" do
    sign_in(admin: false)

    get edit_storage_setting_url
    assert_redirected_to root_url

    patch storage_setting_url, params: { storage_setting: { service: "local" } }
    assert_redirected_to root_url
    assert_equal 0, StorageSetting.count
  end

  test "admins can choose local storage" do
    sign_in(admin: true)

    get edit_storage_setting_url
    assert_response :success

    patch storage_setting_url, params: { storage_setting: { service: "local" } }
    assert_redirected_to edit_storage_setting_url
    assert_equal "local", StorageSetting.sole.service
  end

  test "disables the azure fields unless azure is selected" do
    sign_in(admin: true)

    get edit_storage_setting_url
    assert_select "fieldset[disabled] input[name='storage_setting[azure_container]']"

    StorageSetting.insert!({ service: "azure", azure_storage_account_name: "account", azure_storage_access_key: "key", azure_container: "files" })
    get edit_storage_setting_url
    assert_select "fieldset:not([disabled]) input[name='storage_setting[azure_container]']"
  end

  test "keeps the saved azure details when switching to local" do
    sign_in(admin: true)
    StorageSetting.insert!({ service: "azure", azure_storage_account_name: "account", azure_storage_access_key: "key", azure_container: "files" })

    # Disabled fields aren't submitted, so only the service arrives.
    patch storage_setting_url, params: { storage_setting: { service: "local" } }

    setting = StorageSetting.sole
    assert_equal "local", setting.service
    assert_equal [ "account", "key", "files" ], [ setting.azure_storage_account_name, setting.azure_storage_access_key, setting.azure_container ]
  end

  test "azure requires its details" do
    sign_in(admin: true)

    patch storage_setting_url, params: { storage_setting: { service: "azure", azure_storage_account_name: "", azure_storage_access_key: "", azure_container: "" } }

    assert_response :unprocessable_content
    assert_equal 0, StorageSetting.count
  end

  test "a blank access key keeps the saved key" do
    sign_in(admin: true)
    StorageSetting.create!(service: "local", azure_storage_account_name: "account", azure_storage_access_key: "saved-key", azure_container: "files")

    patch storage_setting_url, params: { storage_setting: { service: "local", azure_storage_account_name: "renamed", azure_storage_access_key: "" } }

    setting = StorageSetting.sole
    assert_equal "renamed", setting.azure_storage_account_name
    assert_equal "saved-key", setting.azure_storage_access_key
  end
end
