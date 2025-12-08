# frozen_string_literal: true

class GithubClientStub
  StubRepo = Struct.new(:id, :name, :full_name, :language, :clone_url, :ssh_url, keyword_init: true)

  def self.repos(access_token:)
    [
      StubRepo.new(
        id: 1,
        name: "example",
        full_name: "TheGor-365/example",
        language: "Ruby",
        clone_url: "https://github.com/TheGor-365/example.git",
        ssh_url: "git@github.com:TheGor-365/example.git"
      )
    ]
  end

  def self.repo(github_id:, access_token:)
    repos(access_token: access_token).find { |repo| repo.id.to_s == github_id.to_s }
  end

  def self.create_webhook(access_token:, repo_full_name:, webhook_url:)
    Rails.logger.info(
      "GithubClientStub.create_webhook(access_token: [FILTERED], repo_full_name: #{repo_full_name}, webhook_url: #{webhook_url})"
    )
  end
end
