# frozen_string_literal: true

require 'open3'

class CommandRunner
  Result = Struct.new(:stdout, :stderr, :status, keyword_init: true)

  class << self
    def capture3(*command, chdir:)
      stdout, stderr, status = Open3.capture3(*command, chdir: chdir)

      Result.new(stdout: stdout, stderr: stderr, status: status)
    end
  end
end
