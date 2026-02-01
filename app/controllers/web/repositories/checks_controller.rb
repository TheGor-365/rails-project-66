# frozen_string_literal: true

module Repositories
  class ChecksController < ApplicationController
    before_action :require_login
    before_action :set_repository

    def create
      @check = @repository.checks.create!
      @check.perform!

      redirect_to repository_path(@repository), notice: t(".success", default: "Проверка запущена")
    end

    def show
      @check = @repository.checks.find(params[:id])
    end

    private

    def set_repository
      @repository = current_user.repositories.find(params[:repository_id])
    end
  end
end
