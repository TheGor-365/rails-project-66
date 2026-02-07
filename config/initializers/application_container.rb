# frozen_string_literal: true

require "dry/container"
require "octokit"

class ApplicationContainer
  extend Dry::Container::Mixin
end

ApplicationContainer.register(:octokit_client_class) do
  Octokit::Client
end

ApplicationContainer.register(:github_client) do
  if Rails.env.test?
    GithubClientStub
  else
    GithubClient
  end
end

ApplicationContainer.register(:code_checker) do
  if Rails.env.test?
    CodeCheckerStub
  else
    CodeChecker
  end
end
