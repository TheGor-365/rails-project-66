# frozen_string_literal: true

require "open3"
require "fileutils"
require "securerandom"
require "json"

class CodeChecker
  Result = Struct.new(:output, :offenses_count, :exit_status, :commit_id, keyword_init: true) do
    def success?
      exit_status.zero?
    end
  end

  class << self
    # Запуск проверки репозитория Rubocop
    # Возвращает Result
    def run(repository:, commit_id: nil)
      repo_path = clone_repository(repository)

      resolved_commit_id = current_commit_id(repo_path)

      stdout, status = Open3.popen3(rubocop_command(repo_path)) do |_stdin, stdout, _stderr, wait_thr|
        [stdout.read, wait_thr.value.exitstatus]
      end

      Result.new(
        output: stdout,
        offenses_count: parse_offenses_count(stdout),
        exit_status: status,
        commit_id: resolved_commit_id
      )
    ensure
      FileUtils.remove_dir(repo_path) if repo_path && Dir.exist?(repo_path)
    end

    private

    def clone_repository(repository)
      base_dir = Rails.root.join("tmp", "repos")
      FileUtils.mkdir_p(base_dir)

      dest_dir = base_dir.join("repository-#{repository.id}-#{SecureRandom.hex(4)}")

      system!("git clone --depth 1 #{repository.clone_url} #{dest_dir}")

      dest_dir
    end

    def current_commit_id(repo_path)
      stdout, = Open3.capture2("git -C #{repo_path} rev-parse HEAD")
      stdout.strip
    end

    def rubocop_command(repo_path)
      config_path = Rails.root.join(".rubocop.yml")
      %(bundle exec rubocop #{repo_path} --config #{config_path} --format json)
    end

    def parse_offenses_count(stdout)
      json = JSON.parse(stdout)
      json.dig("summary", "offense_count")
    rescue JSON::ParserError, NoMethodError
      nil
    end

    def system!(command)
      success = system(command)
      raise "Command failed: #{command}" unless success
    end
  end
end
