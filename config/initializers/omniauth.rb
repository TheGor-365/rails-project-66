Rails.application.config.middleware.use OmniAuth::Builder do
  client_id, client_secret =
    if Rails.env.test?
      ["test_client_id", "test_client_secret"]
    else
      [
        ENV["GITHUB_CLIENT_ID"],
        ENV["GITHUB_CLIENT_SECRET"]
      ]
    end

  if client_id.present? && client_secret.present?
    provider :github,
             client_id,
             client_secret,
             scope: "read:user,user:email,repo"
  else
    Rails.logger.warn("[OmniAuth] GitHub OAuth env vars are missing; provider is not configured")
  end
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.request_validation_phase = nil
