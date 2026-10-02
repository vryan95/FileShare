require "test_helper"

class EntraSettingsControllerTest < ActionDispatch::IntegrationTest
  def sign_in(admin:)
    user = User.create!(name: "User", email: "settings-user@example.com", password: "correct horse battery", admin: admin)
    post login_url, params: { email: user.email, password: "correct horse battery" }
    user
  end

  def entra_params(overrides = {})
    { entra_setting: { client_id: "client", client_secret: "secret", tenant_id: "tenant-guid" }.merge(overrides) }
  end

  test "requires login" do
    get edit_entra_setting_url
    assert_redirected_to login_url
  end

  test "requires an admin" do
    sign_in(admin: false)

    get edit_entra_setting_url
    assert_redirected_to root_url

    patch entra_setting_url, params: entra_params
    assert_redirected_to root_url
    assert_equal 0, EntraSetting.count
  end

  test "admins can save settings" do
    sign_in(admin: true)

    get edit_entra_setting_url
    assert_response :success

    patch entra_setting_url, params: entra_params
    assert_redirected_to edit_entra_setting_url

    setting = EntraSetting.sole
    assert_equal "client", setting.client_id
    assert_equal "secret", setting.client_secret
    assert_equal "tenant-guid", setting.tenant_id
  end

  test "a blank secret keeps the saved secret" do
    sign_in(admin: true)
    EntraSetting.create!(client_id: "client", client_secret: "secret", tenant_id: "tenant-guid")

    patch entra_setting_url, params: entra_params(client_id: "new-client", client_secret: "")

    setting = EntraSetting.sole
    assert_equal "new-client", setting.client_id
    assert_equal "secret", setting.client_secret
  end

  test "rejects shared tenants" do
    sign_in(admin: true)

    patch entra_setting_url, params: entra_params(tenant_id: "common")

    assert_response :unprocessable_content
    assert_equal 0, EntraSetting.count
  end
end
