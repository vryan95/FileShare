# Microsoft Entra ID sign-in settings, entered by an admin so installs (e.g. through ONCE)
# don't need environment variables. Falls back to ENTRA_* env vars when nothing is saved.
class EntraSetting < ApplicationRecord
  SHARED_TENANTS = %w[common organizations consumers].freeze

  validates :client_id, :client_secret, :tenant_id, presence: true
  validates :tenant_id, exclusion: { in: SHARED_TENANTS, message: :shared_tenant }

  normalizes :client_id, :client_secret, :tenant_id, with: ->(value) { value.strip }

  def self.current
    first || from_env
  end

  def self.from_env
    return if ENV["ENTRA_CLIENT_ID"].blank? || ENV["ENTRA_CLIENT_SECRET"].blank?

    new(
      client_id: ENV["ENTRA_CLIENT_ID"],
      client_secret: ENV["ENTRA_CLIENT_SECRET"],
      tenant_id: ENV.fetch("ENTRA_TENANT_ID", "common")
    )
  end

  def self.configured?
    current.present?
  end

  # Passed to the omniauth-entra-id strategy as its tenant provider, so settings are read on every request.
  class TenantProvider
    delegate :client_id, :client_secret, :tenant_id, to: :setting, allow_nil: true

    def initialize(_strategy)
      @setting = EntraSetting.current
    end

    private
      attr_reader :setting
  end
end
