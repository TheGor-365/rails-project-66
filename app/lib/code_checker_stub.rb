# frozen_string_literal: true

class CodeCheckerStub
  Result = Struct.new(:commit_id, :output, :offenses_count, :success) do
    def success?
      !!success
    end
  end

  def self.run(repository:, commit_id: nil)
    _ = repository

    Result.new(commit_id || 'stub-commit-sha', 'rubocop stub output', 0, true)
  end
end
