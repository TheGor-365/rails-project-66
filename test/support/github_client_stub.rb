# frozen_string_literal: true

require "ostruct"

class GithubClientStub
  class << self
    def repos(access_token:)
      @repos ||= [
        build_repo(
          id: 9_100_001,
          name: "rails-project",
          full_name: "hexlet-basics/rails-project",
          language: "Ruby"
        ),
        build_repo(
          id: 9_100_002,
          name: "frontend-check",
          full_name: "hexlet-basics/frontend-check",
          language: "JavaScript"
        )
      ]
    end

    def repo(github_id:, access_token:)
      found_repo = repos(access_token: access_token).find { |repo_item| repo_item.id.to_s == github_id.to_s }
      return found_repo if found_repo

      normalized_id = github_id.to_i
      return nil if normalized_id <= 0

      build_repo(
        id: normalized_id,
        name: "repo-#{normalized_id}",
        full_name: "stub-user/repo-#{normalized_id}",
        language: "Ruby"
      )
    end

    def create_webhook(access_token:, repo_full_name:, webhook_url:)
      Rails.logger.info(
        "GithubClientStub.create_webhook(access_token: [FILTERED], repo_full_name: #{repo_full_name}, webhook_url: #{webhook_url})"
      )
      true
    end

    private

    def build_repo(id:, name:, full_name:, language:)
      OpenStruct.new(
        id: id,
        name: name,
        full_name: full_name,
        language: language,
        clone_url: "https://github.com/#{full_name}.git",
        ssh_url: "git@github.com:#{full_name}.git"
      )
    end
  end
end
