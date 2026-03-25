# frozen_string_literal: true

class CommandRunnerStub
  Status = Struct.new(:ok) do
    def success?
      !!ok
    end
  end

  class << self
    def capture3(*command, chdir:)
      _ = chdir

      if git_clone_command?(command)
        return ['', '', Status.new(true)]
      end

      if git_rev_parse_command?(command)
        return ['', '', Status.new(true)]
      end

      if rubocop_command?(command)
        return ['rubocop stub output', '', Status.new(true)]
      end

      if eslint_command?(command)
        return ['[]', '', Status.new(true)]
      end

      ['', '', Status.new(true)]
    end

    private

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
