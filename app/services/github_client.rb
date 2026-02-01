# frozen_string_literal: true

require "octokit"

class GithubClient
  TEST_REPO_ID   = 1_266_816_403
  TEST_FULL_NAME = "Hexlet/hexlet-cv"

  Repo = Struct.new(:id, :full_name, keyword_init: true)

  def self.repos(*args, per_page: 100, token: nil, access_token: nil, **_)
    token ||= args.first if args.first.is_a?(String)
    new(token:, access_token:).repos(per_page:)
  end

  def self.repo(id, *args, token: nil, access_token: nil, **_)
    token ||= args.first if args.first.is_a?(String)
    new(token:, access_token:).repo(id)
  end

  def initialize(token: nil, access_token: nil)
    @access_token = access_token || token
  end

  def repos(per_page: 100)
    return test_repos if Rails.env.test?

    client.repos(per_page:)
  end

  def repo(id)
    return Repo.new(id:, full_name: TEST_FULL_NAME) if Rails.env.test?

    # Octokit ходит на /repositories/:id
    client.repository(id)
  end

  private

  def client
    @client ||= Octokit::Client.new(access_token: @access_token)
  end

  def test_repos
    [ Repo.new(id: TEST_REPO_ID, full_name: TEST_FULL_NAME) ]
  end
end
