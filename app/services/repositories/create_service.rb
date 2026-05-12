# frozen_string_literal: true

module Repositories
  class CreateService
    Result = Struct.new(:status, :repository, :check, keyword_init: true)

    class << self
      def call(user:, github_id:, github_client:)
        if github_id.blank?
          Rails.logger.warn(
            "[Repositories::CreateService] GitHub repo not found for github_id=#{github_id}"
          )

          repository = user.repositories.build(github_id: github_id)
          repository.errors.add(:github_id, :invalid)

          return Result.new(status: :invalid, repository: repository)
        end

        github_repo = github_client.repo(
          github_id: github_id.to_i,
          access_token: user.token
        )

        unless github_repo
          Rails.logger.warn(
            "[Repositories::CreateService] GitHub repo not found for github_id=#{github_id}"
          )

          repository = user.repositories.build(github_id: github_id)
          repository.errors.add(:github_id, :invalid)

          return Result.new(status: :invalid, repository: repository)
        end

        unless Repository.supported_language?(github_repo.language)
          repository = user.repositories.build(github_id: github_repo.id)
          repository.errors.add(:language, :inclusion)

          return Result.new(status: :invalid, repository: repository)
        end

        existing_repository = user.repositories.find_by(github_id: github_repo.id)

        if existing_repository
          check = existing_repository.checks.create!
          RunRepositoryCheckJob.perform_now(check.id)

          return Result.new(status: :check_created, repository: existing_repository, check: check)
        end

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
