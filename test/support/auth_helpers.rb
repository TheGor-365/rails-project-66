# frozen_string_literal: true

require 'omniauth'
require 'omniauth/auth_hash'

module AuthHelpers
  def sign_in!(email: 'test@example.com', token: '12345')
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github',
      uid: '123',
      info: {
        email: email,
        nickname: 'tester',
        name: 'Tester',
        image: 'http://example.com/avatar.png'
      },
      credentials: { token: token }
    )

    get callback_auth_path(provider: 'github')
    follow_redirect!

    User.find_by!(email: email)
  end
end

class ActionDispatch::IntegrationTest
  include AuthHelpers
end
