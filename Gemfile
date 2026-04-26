# frozen_string_literal: true

source 'https://rubygems.org'

gem 'aasm'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'dotenv-rails', groups: %i[development test]
gem 'dry-container'
gem 'enumerize'
gem 'faraday-retry'
gem 'image_processing', '~> 1.2'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg', '~> 1.6'
gem 'puma', '>= 5.0'
gem 'pundit'
gem 'rails', '~> 7.2.2', '>= 7.2.2.2'
gem 'redis', '>= 4.0.1'
gem 'rollbar'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sprockets-rails'
gem 'sqlite3', '>= 1.4'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-packaging', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'minitest-power_assert'
  gem 'selenium-webdriver'
  gem 'webmock'
end

# Rails 7.2 test runner is not compatible with Minitest 6.x
gem 'minitest', '< 6'

gem 'ostruct', '~> 0.6.3'
