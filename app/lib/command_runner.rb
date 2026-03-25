# frozen_string_literal: true

require 'open3'

class CommandRunner
  class << self
    def capture3(*command, chdir:)
      Open3.capture3(*command, chdir: chdir)
    end
  end
end
