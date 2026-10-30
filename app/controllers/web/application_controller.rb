# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include AuthManagement
    include Pundit::Authorization

    around_action :with_ui_locale

    rescue_from Pundit::NotAuthorizedError, with: :not_found
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def with_ui_locale(&action)
      selected = session[:ui_locale].to_s
      locale = %w[ru en].include?(selected) ? selected.to_sym : I18n.default_locale

      I18n.with_locale(locale, &action)
    end

    def not_found
      render file: Rails.root.join('public/404.html'), layout: false, status: :not_found, content_type: 'text/html'
    end
  end
end
