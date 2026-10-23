# frozen_string_literal: true

require 'test_helper'

class GithubClientTest < ActiveSupport::TestCase
  class FakeOctokitClient
    attr_accessor :auto_paginate
    attr_reader :requested_per_page

    def repos(per_page:)
      @requested_per_page = per_page
      count = auto_paginate ? 175 : per_page

      Array.new(count) { |index| index }
    end
  end

  test 'repos enables Octokit pagination to include repositories after the first page' do
    fake_client = FakeOctokitClient.new

    repositories = GithubClient.stub(:client, fake_client) do
      GithubClient.repos(access_token: 'test-token')
    end

    assert_equal true, fake_client.auto_paginate
    assert_equal 100, fake_client.requested_per_page
    assert_equal 175, repositories.size
  end
end
