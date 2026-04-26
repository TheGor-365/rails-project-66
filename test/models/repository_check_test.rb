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

  def assert_check_not_rerun!(check)
    assert { check.finished? }
    assert { check.status == 'passed' }
    assert { check.commit_id == 'old123' }
    assert { check.output == 'old output' }
    assert { check.violations_count.zero? }
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
  test 'run service does not rerun non-pending check' do
    user = User.create!(email: 'already-finished-check@example.com')
    repo = user.repositories.create!(
      github_id: 2,
      name: 'example-finished',
      full_name: 'TheGor-365/example-finished',
      language: 'ruby',
      clone_url: 'https://github.com/TheGor-365/example-finished.git',
      ssh_url: 'git@github.com:TheGor-365/example-finished.git'
    )

    check = repo.checks.create!(
      commit_id: 'old123',
      output: 'old output',
      passed: true,
      status: 'passed',
      violations_count: 0
    )

    check.run_check!
    check.finish!

    Checks::RunService.run(check: check, commit_id: 'new456')
    check.reload

    assert_check_not_rerun!(check)
  end
end
