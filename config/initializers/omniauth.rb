Rails.application.config.middleware.use OmniAuth::Builder do
  client_id, client_secret =
    if Rails.env.test?
      ['test_client_id', 'test_client_secret']
    else
      [
        ENV.fetch('GITHUB_CLIENT_ID'),
        ENV.fetch('GITHUB_CLIENT_SECRET')
      ]
    end

  provider :github,
           client_id,
           client_secret,
           scope: 'read:user,user:email,repo'
end

OmniAuth.config.allowed_request_methods = [:post]
OmniAuth.config.request_validation_phase = nil
