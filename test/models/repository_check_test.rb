# frozen_string_literal: true

require "test_helper"

class RepositoryCheckTest < ActiveSupport::TestCase
  test "perform! uses code checker from container and updates fields" do
    repo = repositories(:one)

    check = Repository::Check.create!(repository: repo)

    check.perform!

    assert { check.status == "failed" }
    assert { check.passed == false }
    assert { check.commit_id == CodeCheckerStub::FAKE_COMMIT_ID }
    assert { check.output.present? }
    assert { check.violations_count == 3 }
  end
end
