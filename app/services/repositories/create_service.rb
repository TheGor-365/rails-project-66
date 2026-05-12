# frozen_string_literal: true

module Repositories
  class CreateService
    Result = Struct.new(:status, :repository, :check, keyword_init: true)

    class << self
      def call(user:, github_id:, github_client:)
        return invalid_github_repo(user: user, github_id: github_id) if github_id.blank?

        github_repo = find_github_repo(user: user, github_id: github_id, github_client: github_client)
        return invalid_github_repo(user: user, github_id: github_id) unless github_repo
        return unsupported_language(user: user, github_repo: github_repo) unless Repository.supported_language?(github_repo.language)

        existing_repository = user.repositories.find_by(github_id: github_repo.id)
        return create_check(existing_repository) if existing_repository

        create_repository(user: user, github_repo: github_repo)
      end

      private

      def find_github_repo(user:, github_id:, github_client:)
        github_client.repo(
          github_id: github_id.to_i,
          access_token: user.token
        )
      end

      def invalid_github_repo(user:, github_id:)
        Rails.logger.warn(
          "[Repositories::CreateService] GitHub repo not found for github_id=#{github_id}"
        )

        repository = user.repositories.build(github_id: github_id)
        repository.errors.add(:github_id, :invalid)

        Result.new(status: :invalid, repository: repository)
      end

      def unsupported_language(user:, github_repo:)
        repository = user.repositories.build(github_id: github_repo.id)
        repository.errors.add(:language, :inclusion)

        Result.new(status: :invalid, repository: repository)
      end

      def create_check(repository)
        check = repository.checks.create!
        RunRepositoryCheckJob.perform_now(check.id)

        Result.new(status: :check_created, repository: repository, check: check)
      end

      def create_repository(user:, github_repo:)
        repository = user.repositories.build(
          github_id: github_repo.id,
          name: github_repo.name,
          full_name: github_repo.full_name,
          language: github_repo.language.to_s.downcase,
          clone_url: github_repo.clone_url,
          ssh_url: github_repo.ssh_url
        )

        if repository.save
          CreateRepositoryWebhookJob.perform_later(repository.id)
          Result.new(status: :created, repository: repository)
        else
          Rails.logger.error(
            '[Repositories::CreateService] Repository not saved. ' \
            "Errors: #{repository.errors.full_messages.inspect}"
          )

          Result.new(status: :invalid, repository: repository)
        end
      end
    end
  end
end
