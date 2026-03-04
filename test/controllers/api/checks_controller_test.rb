# frozen_string_literal: true

require 'test_helper'

class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  def build_repo(github_id:)
    user = User.create!(email: 'api-owner@example.com')
    user.repositories.create!(
      github_id: github_id,
      name: 'example',
      full_name: 'TheGor-365/example',
      language: 'ruby',
      clone_url: 'https://github.com/TheGor-365/example.git',
      ssh_url: 'git@github.com:TheGor-365/example.git'
    )
  end

  def assert_created_check_state!(repo, commit_id:)
    check = repo.checks.order(created_at: :desc).first

    assert { check.finished? }
    assert { check.status == 'passed' }
    assert { check.commit_id == commit_id }
    assert { check.passed == true }
    assert { check.violations_count.zero? }
  end

  test 'create returns ok and creates check' do
    repo = build_repo(github_id: 345)

    payload = {
      'repository' => { 'id' => repo.github_id, 'full_name' => repo.full_name },
      'after' => 'abc123def456'
    }

    assert_difference -> { repo.checks.count }, 1 do
      post api_checks_path,
           params: payload.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json' }
    end

    assert_response :ok
    assert_created_check_state!(repo, commit_id: 'abc123def456')
  end

  test 'create returns not_found when repository does not exist' do
    payload = { 'repository' => { 'id' => 999_999 }, 'after' => 'x' }

    post api_checks_path,
         params: payload.to_json,
         headers: { 'CONTENT_TYPE' => 'application/json' }

    assert_response :not_found
  end

  test 'create returns unprocessable_entity on invalid json' do
    post api_checks_path, params: '{', headers: { 'CONTENT_TYPE' => 'application/json' }

    assert_response :unprocessable_entity
  end
end
