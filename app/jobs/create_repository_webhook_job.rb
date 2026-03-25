# frozen_string_literal: true

class CreateRepositoryWebhookJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)
    github_client = ApplicationContainer[:github_client]

    github_client.create_webhook(
      access_token: repository.user.token,
      repo_full_name: repository.full_name,
      webhook_url: webhook_url
    )
  end

  private

  def webhook_url
    Rails.application.routes.url_helpers.api_checks_url(
      host: ENV.fetch('APP_HOST', 'localhost'),
      protocol: ENV.fetch('APP_PROTOCOL', 'http')
    )
  end
end
