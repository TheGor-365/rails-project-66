# frozen_string_literal: true

class CodeCheckerStub
  Result = Struct.new(:output, :offenses_count, :exit_status, :commit_id, keyword_init: true) do
    def success?
      exit_status.zero?
    end
  end

  FAKE_COMMIT_ID = "stub-commit-sha"

  def self.run(repository:, commit_id: nil)
    Result.new(
      output: "rubocop stub output",
      offenses_count: 3,
      exit_status: 1, # не прошла
      commit_id: FAKE_COMMIT_ID
    )
  end
end
