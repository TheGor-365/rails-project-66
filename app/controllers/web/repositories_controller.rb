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

      @github_repositories = cached_github_repositories(github_client)
      @repository = current_user.repositories.build
    end

    def create
      github_client = ApplicationContainer[:github_client]

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
        @github_repositories = cached_github_repositories(github_client)
        render :new, status: :unprocessable_content
        return
      end

      existing_repository = current_user.repositories.find_by(github_id: github_repo.id)

      if existing_repository
        check = existing_repository.checks.create!
        RunRepositoryCheckJob.perform_now(check.id)

        redirect_to repository_check_path(existing_repository, check),
                    notice: t('web.repositories.checks.create.success', default: t('flash.repositories.created'))
        return
      end

      @repository = current_user.repositories.build(
        github_id: github_repo.id,
        name: github_repo.name,
        full_name: github_repo.full_name,
        language: github_repo.language.to_s.downcase,
        clone_url: github_repo.clone_url,
        ssh_url: github_repo.ssh_url
      )

      if @repository.save
        CreateRepositoryWebhookJob.perform_later(@repository.id)
        redirect_to repositories_path, notice: t('flash.repositories.created')
      else
        Rails.logger.error(
          '[RepositoriesController#create] Repository not saved. ' \
          "Errors: #{@repository.errors.full_messages.inspect}"
        )

        @github_repositories = cached_github_repositories(github_client)
        render :new, status: :unprocessable_content
      end
    end

    private

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
