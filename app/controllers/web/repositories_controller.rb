# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :require_login!

    def index
      @repositories = current_user.repositories.order(created_at: :desc)
    end

    def show
      @repository = current_user.repositories.find(params[:id])
      @checks = @repository.checks.order(created_at: :desc)
    end

    def new
      github_client = ApplicationContainer[:github_client]

      @github_repositories = supported_github_repositories(github_client)
      @repository = current_user.repositories.build
    end

    def create
      github_client = ApplicationContainer[:github_client]
      result = ::Repositories::CreateService.call(
        user: current_user,
        github_id: github_id_param,
        github_client: github_client
      )

      @repository = result.repository

      case result.status
      when :created
        redirect_to repositories_path, notice: t('flash.repositories.created')
      when :check_created
        redirect_to repository_check_path(result.repository, result.check),
                    notice: t('web.repositories.checks.create.success', default: t('flash.repositories.created'))
      else
        render_new_form(github_client, status: :unprocessable_content)
      end
    end

    private

    def render_new_form(github_client, status:)
      @github_repositories = supported_github_repositories(github_client)
      render :new, status:
    end

    def supported_github_repositories(github_client)
      cached_github_repositories(github_client).select do |repo|
        Repository.supported_language?(repo.language)
      end
    end

    def cached_github_repositories(github_client)
      Rails.cache.fetch([:github_repositories, current_user.cache_key_with_version], expires_in: 5.minutes) do
        github_client.repos(access_token: current_user.token)
      end
    end

    def github_id_param
      params.require(:repository).fetch(:github_id)
    end
  end
end
