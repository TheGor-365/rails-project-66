# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include AuthManagement
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :not_found
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def not_found
      head :not_found
    end
  end
end
