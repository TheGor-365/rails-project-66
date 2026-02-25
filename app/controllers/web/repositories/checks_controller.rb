# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < Web::ApplicationController
      before_action :require_login
      before_action :set_repository

      def show
        @check = @repository.checks.find(params[:id])
        render :show, formats: [ :html ]
      end

      def create
        @check = @repository.checks.create!
        @check.perform!

        redirect_to repository_path(@repository), notice: t('.success', default: 'Проверка запущена')
      end

      private

      def set_repository
        @repository = current_user.repositories.find(params[:repository_id])
      end
    end
  end
end
