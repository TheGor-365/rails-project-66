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
end
