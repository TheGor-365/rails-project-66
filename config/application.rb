require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

if %w[development test].include?(ENV.fetch("RAILS_ENV", "development"))
  begin
    require "dotenv/load"
  rescue LoadError
  end
end

module RailsProject66
  class Application < Rails::Application
    config.load_defaults 7.2
    config.autoload_lib(ignore: %w[assets tasks])

    routes.default_url_options = {
      host: ENV.fetch("BASE_URL", "http://localhost:3000")
    }
  end
end
