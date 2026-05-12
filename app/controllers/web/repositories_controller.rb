# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :require_login!

    def index
      @repositories = current_user.repositories.order(created_at: :desc)
    end

    def show
      @repository = Repository.find(params[:id])
      authorize @repository

      @checks = @repository.checks.order(created_at: :desc)
    end

    def new
      github_client = ApplicationContainer[:github_client]

      @github_repositories = supported_github_repositories(github_client)
      @repository = current_user.repositories.build
    end

    def create
      if github_id_param.blank?
        github_client = ApplicationContainer[:github_client]
        @repository = current_user.repositories.build(github_id: github_id_param)
        @repository.errors.add(:github_id, :invalid)

        render_new_form_with_repositories(github_client, status: :unprocessable_content)
        return
      end

      CreateRepositoryFromGithubJob.perform_later(current_user.id, github_id_param)

      redirect_to repositories_path, notice: t('flash.repositories.created')
    end

    private

    def render_new_form_with_repositories(github_client, status:)
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
