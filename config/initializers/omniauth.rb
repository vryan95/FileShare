Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :entra_id,
    {
      client_id:     ENV["ENTRA_CLIENT_ID"],
      client_secret: ENV["ENTRA_CLIENT_SECRET"],
      tenant_id:     ENV.fetch("ENTRA_TENANT_ID", "common")
    }
  )
end

# Handle OmniAuth failure
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
