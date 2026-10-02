# Entra ID settings are read per request from EntraSetting (saved by an admin, or ENTRA_* env vars).
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :entra_id, EntraSetting::TenantProvider
end

# Handle OmniAuth failure
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
