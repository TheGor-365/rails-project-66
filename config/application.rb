require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
Dotenv::Rails.load

module RailsProject66
  class Application < Rails::Application
    config.load_defaults 7.2
    config.autoload_lib(ignore: %w[assets tasks])

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
