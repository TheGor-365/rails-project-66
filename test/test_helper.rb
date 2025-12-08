ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/power_assert"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true)

Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |f| require f }

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all
  end
end
