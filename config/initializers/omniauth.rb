require "omniauth-github"

scope = "read:user,user:email,repo"

if Rails.env.test?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, "test_client_id", "test_client_secret", scope: scope
  end
else
  client_id = ENV["GITHUB_CLIENT_ID"]
  client_secret = ENV["GITHUB_CLIENT_SECRET"]

  if client_id.present? && client_secret.present?
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :github, client_id, client_secret, scope: scope
    end
  else
    Rails.logger.warn("[OmniAuth] GitHub OAuth env vars are missing; provider is not configured")
  end
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.request_validation_phase = nil if Rails.env.test?
