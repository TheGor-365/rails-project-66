# frozen_string_literal: true

require 'octokit'

class GithubClient
  class << self
    def repos(access_token:, per_page: 100)
      client(access_token).repos(per_page:)
    end

    def repo(github_id:, access_token:)
      client(access_token).repository(github_id)
    end

    def create_webhook(access_token:, repo_full_name:, webhook_url:)
      config = { url: webhook_url, content_type: 'json' }
      options = { events: [ 'push' ], active: true }

      client(access_token).create_hook(repo_full_name, 'web', config, options)
    end

    private

    def client(access_token)
      client_class = ApplicationContainer[:octokit_client_class]
      client_class.new(access_token:)
    rescue KeyError
      Octokit::Client.new(access_token:)
    end
  end
end
