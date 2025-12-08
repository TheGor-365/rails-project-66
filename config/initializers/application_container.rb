# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin
end

# Github-клиент: Octokit в проде, заглушка в тестах
ApplicationContainer.register(:github_client) do
  if Rails.env.test?
    GithubClientStub
  else
    GithubClient
  end
end

# Линтер (Rubocop): реальный в проде, заглушка в тестах
ApplicationContainer.register(:code_checker) do
  if Rails.env.test?
    CodeCheckerStub
  else
    CodeChecker
  end
end
