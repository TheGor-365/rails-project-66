# frozen_string_literal: true

module ForceHtmlFormat
  extend ActiveSupport::Concern

  included do
    before_action :force_html_format_unless_api
  end

  private

  def force_html_format_unless_api
    return if controller_path.start_with?("api/")
    return if request.format.html?

    request.format = :html
  end
end

Rails.application.config.to_prepare do
  base = ActionController::Base
  next if base.included_modules.include?(ForceHtmlFormat)

  base.include(ForceHtmlFormat)
end
