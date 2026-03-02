# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :require_login
    before_action :set_repository, only: %i[show]

    def index
      @repositories = current_user.repositories.order(created_at: :desc)
      render :index, formats: [:html]
    end

    def show
      @checks = @repository.checks.order(created_at: :desc)
      render :show, formats: [:html]
    end

    def new
      github_client = ApplicationContainer[:github_client]

      @github_repositories = github_client.repos(access_token: current_user.token)
      @repository = current_user.repositories.build

      render :new, formats: [:html]
    end

    def create
      github_client = ApplicationContainer[:github_client]

      github_id_param = params.require(:repository).fetch(:github_id)

      github_repo = github_client.repo(
        github_id: github_id_param.to_i,
        access_token: current_user.token
      )

      if github_repo.nil?
        Rails.logger.warn(
          "[RepositoriesController#create] GitHub repo not found for github_id=#{github_id_param}"
        )

        @repository = current_user.repositories.build(github_id: github_id_param)
        @repository.errors.add(:github_id, :invalid)
        @github_repositories = github_client.repos(access_token: current_user.token)
        render :new, status: :unprocessable_content, formats: [:html]
        return
      end

      @repository = current_user.repositories.build(
        github_id: github_repo.id,
        name: github_repo.name,
        full_name: github_repo.full_name,
        language: github_repo.language,
        clone_url: github_repo.clone_url,
        ssh_url: github_repo.ssh_url
      )

      if @repository.save
        webhook_url = Rails.application.routes.url_helpers.api_checks_url(
          host: ENV.fetch('APP_HOST', 'localhost'),
          protocol: ENV.fetch('APP_PROTOCOL', 'http')
        )

        github_client.create_webhook(
          access_token: current_user.token,
          repo_full_name: @repository.full_name,
          webhook_url: webhook_url
        )

        redirect_to repositories_path, notice: t('flash.repositories.created')
      else
        Rails.logger.error(
          '[RepositoriesController#create] Repository not saved. ' \
          "Errors: #{@repository.errors.full_messages.inspect}"
        )

        @github_repositories = github_client.repos(access_token: current_user.token)
        render :new, status: :unprocessable_content, formats: [:html]
      end
    end

    private

    def set_repository
      @repository = current_user.repositories.find(params[:id])
    end
  end
end
