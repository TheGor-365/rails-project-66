# frozen_string_literal: true

class GithubClientStub
  RepoStub = Struct.new(
    :id,
    :name,
    :full_name,
    :language,
    :clone_url,
    :ssh_url
  )

  def self.repos(**)
    [
      RepoStub.new(
        id: 9_100_001,
        name: 'rails-project',
        full_name: 'TheGor-365/rails-project',
        language: 'Ruby',
        clone_url: 'https://github.com/TheGor-365/rails-project.git',
        ssh_url: 'git@github.com:TheGor-365/rails-project.git'
      ),
      RepoStub.new(
        id: 9_100_002,
        name: 'frontend-check',
        full_name: 'TheGor-365/frontend-check',
        language: 'JavaScript',
        clone_url: 'https://github.com/TheGor-365/frontend-check.git',
        ssh_url: 'git@github.com:TheGor-365/frontend-check.git'
      )
    ]
  end

  def self.repo(github_id:, **)
    normalized_id = github_id.to_i
    full_name = "TheGor-365/repo-#{normalized_id}"

    RepoStub.new(
      id: normalized_id,
      name: "repo-#{normalized_id}",
      full_name: full_name,
      language: 'Ruby',
      clone_url: "https://github.com/#{full_name}.git",
      ssh_url: "git@github.com:#{full_name}.git"
    )
  end

  # Контроллер не использует return value. Возвращаем nil, чтобы RuboCop
  # не пытался трактовать метод как predicate.
  def self.create_webhook(**)
    nil
  end
end
