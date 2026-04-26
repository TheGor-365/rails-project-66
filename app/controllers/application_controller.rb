# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern if Rails.env.production?
end
