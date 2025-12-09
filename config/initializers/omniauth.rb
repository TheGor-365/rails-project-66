Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
           ENV.fetch('GITHUB_CLIENT_ID'),
           ENV.fetch('GITHUB_CLIENT_SECRET'),
           scope: 'read:user,user:email,repo'
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.request_validation_phase = nil
