# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/power_assert'
require 'webmock/minitest'

WebMock.disable_net_connect!(allow_localhost: true)

Rails.root.glob('test/support/**/*.rb').each { |f| require f }

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

# Nested fixtures like test/fixtures/repository/checks.yml are named "repository/checks".
# Without explicit mapping Rails may treat association keys (repository: one) as raw columns.
set_fixture_class(
  'repository/checks' => 'RepositoryCheck',
  repository_checks: 'RepositoryCheck'
)
  end
end
