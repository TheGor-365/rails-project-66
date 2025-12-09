# frozen_string_literal: true

require 'open3'
require 'fileutils'
require 'json'
require 'securerandom'

class CodeChecker
  RUBY       = 'Ruby'
  JAVASCRIPT = 'JavaScript'

  # Контракт, под который заточена Repository::Check:
  # - commit_id
  # - output (сырое JSON или текст)
  # - offenses_count (общее число нарушений)
  # - success? (true/false)
  Result = Struct.new(
    :commit_id,
    :output,
    :offenses_count,
    :success,
    keyword_init: true
  ) do
    def success?
      !!success
    end
  end

  # Публичный интерфейс для контейнера:
  # ApplicationContainer[:code_checker].run(repository:, commit_id:)
  def self.run(repository:, commit_id: nil)
    new(repository:, commit_id:).run
  end

  def initialize(repository:, commit_id: nil)
    @repository = repository
    @commit_id  = commit_id
  end

  def run
    repo_path = clone_repository

    commit_id = current_commit_sha(repo_path)

    output         = ''
    offenses_count = 0
    success        = false

    case @repository.language.to_s
    when RUBY
      output, offenses_count, success = run_rubocop(repo_path)
    when JAVASCRIPT
      output, offenses_count, success = run_eslint(repo_path)
    else
      output         = "Unsupported language for check: #{@repository.language}"
      offenses_count = 0
      success        = false
    end

    Result.new(
      commit_id:,
      output:,
      offenses_count:,
      success:
    )
  ensure
    FileUtils.rm_rf(repo_path) if repo_path && Dir.exist?(repo_path)
  end

  private

  # ВАЖНО:
  # Не клонируем в tmp/, потому что RuboCop-конфиг почти наверняка содержит:
  #   AllCops:
  #     Exclude:
  #       - tmp/**/*
  # Из-за этого все файлы в tmp/repos/... игнорируются и мы получаем 0 нарушений.
  def clone_repository
    base_dir = Rails.root.join('repos') # вне tmp/
    FileUtils.mkdir_p(base_dir)

    dir = base_dir.join("repo-#{@repository.id}-#{SecureRandom.hex(4)}")
    FileUtils.mkdir_p(dir)

    clone_url = @repository.clone_url

    command = [
      'git', 'clone',
      '--depth', '1',
      clone_url,
      dir.to_s
    ]

    _stdout, stderr, status = Open3.capture3(*command, chdir: Rails.root.to_s)

    raise "Failed to clone repository: #{stderr}" unless status.success?

    dir
  end

  def current_commit_sha(repo_path)
    stdout, _stderr, status = Open3.capture3(
      'git', '-C', repo_path.to_s, 'rev-parse', 'HEAD'
    )

    status.success? ? stdout.strip : nil
  end

  def run_rubocop(repo_path)
    config_path = Rails.root.join('.rubocop.yml')

    command = [
      'bundle', 'exec', 'rubocop',
      '--config', config_path.to_s,
      '--format', 'json',
      repo_path.to_s
    ]

    stdout, _stderr, status = Open3.capture3(*command, chdir: Rails.root.to_s)

    offenses_count = 0

    begin
      data    = JSON.parse(stdout)
      summary = data.fetch('summary', {})
      offenses_count = summary.fetch('offense_count', 0).to_i
    rescue JSON::ParserError
      # stdout просто показываем как есть
    end

    success = status.success? && offenses_count.zero?

    [stdout, offenses_count, success]
  end

  def run_eslint(repo_path)
    eslint_bin  = Rails.root.join('node_modules', '.bin', 'eslint')
    config_path = Rails.root.join('config', 'eslint', '.eslintrc.json')

    command = [
      eslint_bin.to_s,
      '--no-eslintrc',
      '--config', config_path.to_s,
      '--format', 'json',
      repo_path.to_s
    ]

    stdout, _stderr, status = Open3.capture3(*command, chdir: Rails.root.to_s)

    offenses_count = 0

    begin
      data = JSON.parse(stdout)
      # eslint => массив файлов [{ "messages": [...] }, ...]
      offenses_count = data.sum { |file| file.fetch('messages', []).size }
    rescue JSON::ParserError
      # stdout оставляем как есть
    end

    success = status.success? && offenses_count.zero?

    [stdout, offenses_count, success]
  end
end
