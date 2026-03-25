# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  register(:octokit_client_class) { Octokit::Client }

  if Rails.env.test?
    register(:github_client) { GithubClientStub }
    register(:code_checker) { CodeCheckerStub }
  else
    register(:github_client) { GithubClient }
    register(:code_checker) { CodeChecker }
  end
end
