# frozen_string_literal: true

require 'test_helper'

class Web::Repositories::ChecksControllerTest < ActionDispatch::IntegrationTest
  def build_repo_for(user)
    user.repositories.create!(
      github_id: 10,
      name: 'example',
      full_name: 'TheGor-365/example',
      language: 'ruby',
      clone_url: 'https://github.com/TheGor-365/example.git',
      ssh_url: 'git@github.com:TheGor-365/example.git'
    )
  end

  def assert_latest_check_passed!(repo)
    check = repo.checks.order(created_at: :desc).first

    assert { check.finished? }
    assert { check.status == 'passed' }
    assert { check.passed == true }
  end

  test 'guest is redirected from create' do
    user = User.create!(email: 'u1@example.com')
    repo = build_repo_for(user)

    post repository_checks_path(repo)

    assert_redirected_to root_path
  end

  test 'guest is redirected from show' do
    user = User.create!(email: 'u1@example.com')
    repo = build_repo_for(user)
    check = repo.checks.create!

    get repository_check_path(repo, check)

    assert_redirected_to root_path
  end

  test 'create creates check, performs it, redirects' do
    user = sign_in!
    repo = build_repo_for(user)

    assert_difference -> { repo.checks.count }, 1 do
      post repository_checks_path(repo)
    end

    assert_redirected_to repository_path(repo)
    assert_latest_check_passed!(repo)
  end

  test 'show returns success for owner' do
    user = sign_in!
    repo = build_repo_for(user)
    check = repo.checks.create!
    RunRepositoryCheckJob.perform_now(check.id, 'abc123')

    get repository_check_path(repo, check)

    assert_response :success
  end

  test 'show renders RuboCop offenses without raising an error' do
    user = sign_in!
    repo = build_repo_for(user)
    output = {
      'files' => [
        { 'path' => "/tmp/github-quality-repos/repo-#{repo.id}-a1b2c3d4/app/example.rb", 'offenses' => [
          { 'message' => 'A lint finding', 'cop_name' => 'Lint/Syntax',
            'location' => { 'line' => 1, 'column' => 1 } }
        ] }
      ],
      'summary' => { 'offense_count' => 1, 'inspected_file_count' => 1 }
    }.to_json
    check = repo.checks.create!(
      commit_id: 'abc123def456', status: 'failed', passed: false,
      violations_count: 1, output:
    )

    get repository_check_path(repo, check)

    assert_response :success
    assert_select 'a[href="https://github.com/TheGor-365/example/blob/abc123def456/app/example.rb"]'
    assert_select 'a[href="https://github.com/TheGor-365/example/blob/abc123def456/app/example.rb#L1"]'
    assert_select 'td', text: 'A lint finding'
    assert_select 'p', text: /Files inspected|Файлов проверено/
    assert_select 'a', text: /tmp\/github-quality-repos/, count: 0
  end

  test 'show does not print raw JSON for a successful lint run' do
    user = sign_in!
    repo = build_repo_for(user)
    check = repo.checks.create!(
      commit_id: 'abc123def456', status: 'passed', passed: true,
      violations_count: 0,
      output: { 'files' => [], 'summary' => { 'offense_count' => 0, 'inspected_file_count' => 5 } }.to_json
    )

    get repository_check_path(repo, check)

    assert_response :success
    assert_select 'pre', count: 0
    assert_select 'p', text: /5/
  end
end
