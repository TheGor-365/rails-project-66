# frozen_string_literal: true

class CodeCheckerStub
  Result = Struct.new(:commit_id, :output, :offenses_count, :success, keyword_init: true) do
    def success?
      !!success
    end
  end

  def self.run(repository:, commit_id: nil)
    _ = repository # интерфейс совместим

    Result.new(
      commit_id: commit_id || 'stub-commit-sha',
      output: 'rubocop stub output',
      offenses_count: 0,
      success: true
    )
  end
end
