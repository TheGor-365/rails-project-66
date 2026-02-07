# frozen_string_literal: true

require "test_helper"

class RepositoryCheckTest < ActiveSupport::TestCase
  test "perform! uses code_checker from container and updates fields" do
    user = User.create!(email: "model-owner@example.com")
    repo = user.repositories.create!(
      github_id: 1,
      name: "example",
      full_name: "TheGor-365/example",
      language: "Ruby",
      clone_url: "https://github.com/TheGor-365/example.git",
      ssh_url: "git@github.com:TheGor-365/example.git"
    )

    check = repo.checks.create!
    check.perform!(commit_id: "abc123")

    check.reload

    assert { check.finished? }
    assert { check.status == "passed" }
    assert { check.passed == true }
    assert { check.violations_count == 0 }
    assert { check.commit_id == "abc123" }
    assert { check.output == "rubocop stub output" }
  end
end
