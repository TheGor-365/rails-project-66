# frozen_string_literal: true

module Web
  module Repositories
    class ApplicationController < Web::ApplicationController
      before_action :require_login!
    end
  end
end
