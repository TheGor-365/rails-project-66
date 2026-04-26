# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < ApplicationController
      def show
        @repository = Repository.find(params[:repository_id])
        authorize @repository, :show?

        @check = @repository.checks.find(params[:id])
      end

      def create
        @repository = Repository.find(params[:repository_id])
        authorize @repository, :show?

        @check = @repository.checks.create!
        RunRepositoryCheckJob.perform_now(@check.id)

        redirect_to repository_path(@repository), notice: t('.success', default: 'Проверка запущена')
      end
    end
  end
end
