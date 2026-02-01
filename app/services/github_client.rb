# frozen_string_literal: true

require "octokit"
require "ostruct"

class GithubClient
  TEST_REPO_ID   = 1_266_816_403
  TEST_FULL_NAME = "Hexlet/hexlet-cv"

  def initialize(token: nil, access_token: nil)
    @access_token = access_token || token
  end

  def repos(per_page: 100)
    return test_repos if Rails.env.test?

    client.repos(per_page:)
  end

  def repo(id)
    return OpenStruct.new(id:, full_name: TEST_FULL_NAME) if Rails.env.test?

    # Octokit ходит на /repositories/:id
    client.repository(id)
  end

  private

  def client
    @client ||= Octokit::Client.new(access_token: @access_token)
  end

  def test_repos
    [
      OpenStruct.new(id: TEST_REPO_ID, full_name: TEST_FULL_NAME)
    ]
  end
end
