# frozen_string_literal: true

module Web
  class LanguagesController < ApplicationController
    def update
      locale = params[:locale]
      return head :not_found unless %w[ru en].include?(locale)

      session[:ui_locale] = locale
      redirect_back fallback_location: root_path,
                    allow_other_host: false,
                    status: :see_other
    end
  end
end
