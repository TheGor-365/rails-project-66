# frozen_string_literal: true

class CreateRepositoryFromGithubJob < ApplicationJob
  queue_as :default

  def perform(user_id, github_id)
    user = User.find(user_id)

    result = Repositories::CreateService.call(
      user: user,
      github_id: github_id,
      github_client: ApplicationContainer[:github_client]
    )

    log_invalid_result(user_id, github_id, result) if result.status == :invalid
  end

  private

  def log_invalid_result(user_id, github_id, result)
    errors =
      if result.repository
        result.repository.errors.full_messages.inspect
      else
        '[]'
      end

    Rails.logger.warn(
      '[CreateRepositoryFromGithubJob] Repository creation failed. ' \
      "user_id=#{user_id} github_id=#{github_id} errors=#{errors}"
    )
  end
end
