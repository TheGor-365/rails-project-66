# frozen_string_literal: true

require 'test_helper'

class RepositoryCheckTest < ActiveSupport::TestCase
  def assert_performed_check_fields!(check)
    assert { check.finished? }
    assert { check.status == 'passed' }
    assert { check.passed == true }
    assert { check.violations_count.zero? }
    assert { check.commit_id == 'abc123' }
    assert { check.output == 'rubocop stub output' }
  end

  test 'perform! uses code_checker from container and updates fields' do
    user = User.create!(email: 'model-owner@example.com')
    repo = user.repositories.create!(
      github_id: 1,
      name: 'example',
      full_name: 'TheGor-365/example',
      language: 'ruby',
      clone_url: 'https://github.com/TheGor-365/example.git',
      ssh_url: 'git@github.com:TheGor-365/example.git'
    )

    check = repo.checks.create!
    RunRepositoryCheckJob.perform_now(check.id, 'abc123')
    check.reload

    assert_performed_check_fields!(check)
  end
end
