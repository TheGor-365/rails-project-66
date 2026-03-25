# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  register(:octokit_client_class) { Octokit::Client }
  register(:code_checker) { CodeChecker }

  if Rails.env.test?
    register(:github_client) { GithubClientStub }
    register(:command_runner) { CommandRunnerStub }
  else
    register(:github_client) { GithubClient }
    register(:command_runner) { CommandRunner }
  end
end
