require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

begin
  require "dotenv/rails-now"
rescue LoadError
end

module RailsProject66
  class Application < Rails::Application
    config.load_defaults 7.2
    config.autoload_lib(ignore: %w[assets tasks])
    routes.default_url_options = { host: ENV.fetch("BASE_URL", "http://localhost:3000") }
  end
end
