# frozen_string_literal: true

class CommandRunnerStub
  Status = Struct.new(:ok) do
    def success?
      !!ok
    end
  end

  Result = Struct.new(:stdout, :stderr, :status, keyword_init: true)

  class << self
    def capture3(*command, chdir:)
      _ = chdir

      if git_clone_command?(command)
        return success_result(stdout: '')
      end

      if git_rev_parse_command?(command)
        return success_result(stdout: '')
      end

      if rubocop_command?(command)
        return success_result(stdout: 'rubocop stub output')
      end

      if eslint_command?(command)
        return success_result(stdout: '[]')
      end

      success_result(stdout: '')
    end

    private

    def success_result(stdout:)
      Result.new(stdout: stdout, stderr: '', status: Status.new(true))
    end

    def git_clone_command?(command)
      command[0] == 'git' && command[1] == 'clone'
    end

    def git_rev_parse_command?(command)
      command[0] == 'git' && command.include?('rev-parse') && command.include?('HEAD')
    end

    def rubocop_command?(command)
      command.include?('rubocop')
    end

    def eslint_command?(command)
      command.any? { |part| part.to_s.include?('eslint') }
    end
  end
end
