require "test_helper"

class EntraSettingTest < ActiveSupport::TestCase
  def with_env(values)
    original = values.keys.index_with { |key| ENV[key] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each { |key, value| ENV[key] = value }
  end

  test "rejects shared tenants" do
    EntraSetting::SHARED_TENANTS.each do |tenant_id|
      setting = EntraSetting.new(client_id: "client", client_secret: "secret", tenant_id: tenant_id)

      assert_not setting.valid?
      assert_includes setting.errors[:tenant_id], "must be your organization's tenant ID, not a shared tenant"
    end
  end

  test "current prefers saved settings over env vars" do
    saved = EntraSetting.create!(client_id: "saved-client", client_secret: "saved-secret", tenant_id: "saved-tenant")

    with_env("ENTRA_CLIENT_ID" => "env-client", "ENTRA_CLIENT_SECRET" => "env-secret") do
      assert_equal saved, EntraSetting.current
    end
  end

  test "current falls back to env vars" do
    with_env("ENTRA_CLIENT_ID" => "env-client", "ENTRA_CLIENT_SECRET" => "env-secret", "ENTRA_TENANT_ID" => nil) do
      setting = EntraSetting.current

      assert_equal "env-client", setting.client_id
      assert_equal "env-secret", setting.client_secret
      assert_equal "common", setting.tenant_id
    end
  end

  test "is not configured without saved settings or env vars" do
    with_env("ENTRA_CLIENT_ID" => nil, "ENTRA_CLIENT_SECRET" => nil) do
      assert_not EntraSetting.configured?
    end
  end

  test "tenant provider exposes the current settings" do
    EntraSetting.create!(client_id: "saved-client", client_secret: "saved-secret", tenant_id: "saved-tenant")
    provider = EntraSetting::TenantProvider.new(nil)

    assert_equal "saved-client", provider.client_id
    assert_equal "saved-secret", provider.client_secret
    assert_equal "saved-tenant", provider.tenant_id
  end
end
