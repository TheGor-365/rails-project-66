# frozen_string_literal: true

require 'open3'
require 'fileutils'
require 'json'
require 'securerandom'
require 'uri'
require 'pathname'

class CodeChecker
  RUBY       = 'Ruby'
  JAVASCRIPT = 'JavaScript'

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

  def clone_repository
    default_dir = Rails.root.join('tmp', 'repos').to_s
    base_dir = Pathname.new(ENV.fetch('REPOS_DIR', default_dir))
    FileUtils.mkdir_p(base_dir)

    dir = base_dir.join("repo-#{@repository.id}-#{SecureRandom.hex(4)}")
    FileUtils.mkdir_p(dir)

    clone_url = sanitize_clone_url(@repository.clone_url)

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

  def sanitize_clone_url(raw_url)
    url = raw_url.to_s.strip

    # Поддерживаем стандартные GitHub HTTPS-URL
    if url.start_with?('https://github.com/')
      return url
    end

    # Поддерживаем SSH-формат git@github.com:user/repo.git
    if url.start_with?('git@github.com:')
      return url
    end

    # На всякий случай — базовая проверка через URI (для нестандартных, но валидных https-URL)
    begin
      uri = URI.parse(url)
      if %w[http https].include?(uri.scheme) && uri.host == 'github.com'
        return url
      end
    rescue URI::InvalidURIError
      # упадём чуть ниже с ArgumentError
    end

    raise ArgumentError, 'Unsupported clone URL (only GitHub HTTPS/SSH URLs are allowed)'
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
      offenses_count = data.sum { |file| file.fetch('messages', []).size }
    rescue JSON::ParserError
    end

    success = status.success? && offenses_count.zero?

    [stdout, offenses_count, success]
  end
end
