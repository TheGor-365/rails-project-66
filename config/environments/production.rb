# frozen_string_literal: true

require "active_support/core_ext/integer/time"
require "ipaddr"

Rails.application.configure do
  # config.require_master_key = true
  # config.public_file_server.enabled = false
  # config.assets.css_compressor = :sass
  # config.asset_host = "http://assets.example.com"
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]
  # config.cache_store = :mem_cache_store
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "rails_project_66_production"
  # caching is enabled.
  # config.action_mailer.raise_delivery_errors = false
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  config.assume_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  config.force_ssl = true

  default_trusted =
    if defined?(ActionDispatch::RemoteIp::TRUSTED_PROXIES)
      ActionDispatch::RemoteIp::TRUSTED_PROXIES
    else
      []
    end

  config.action_dispatch.trusted_proxies = default_trusted + [IPAddr.new("100.64.0.0/10")]
  config.action_controller.forgery_protection_origin_check = false

  config.assets.compile = false
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.active_storage.service = :local

  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # === URL options for production (Railway) ===
  app_host = ENV["APP_HOST"].to_s.strip
  app_protocol = ENV["APP_PROTOCOL"].to_s.strip

  app_host = "localhost" if app_host.empty?
  app_protocol = "https" if app_protocol.empty?

  config.action_mailer.default_url_options = { host: app_host, protocol: app_protocol }

  Rails.application.routes.default_url_options[:host] = app_host
  Rails.application.routes.default_url_options[:protocol] = app_protocol
end
