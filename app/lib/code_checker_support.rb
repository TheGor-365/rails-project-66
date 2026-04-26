# frozen_string_literal: true

require 'json'

module CodeCheckerSupport
  private

  def sanitize_clone_url(raw_url)
    url = raw_url.to_s.strip

    return url if github_clone_url?(url)

    raise ArgumentError, 'Unsupported clone URL (only GitHub HTTPS/SSH URLs are allowed)'
  end

  def github_clone_url?(url)
    url.start_with?('https://github.com/', 'http://github.com/', 'git@github.com:')
  end

  def rubocop_offenses_count(output)
    data = parse_json_output(output, parser_name: 'rubocop')
    return 0 unless data.is_a?(Hash)

    summary = data.fetch('summary', {})
    summary.fetch('offense_count', 0).to_i
  end

  def eslint_offenses_count(output)
    data = parse_json_output(output, parser_name: 'eslint')
    return 0 unless data.is_a?(Array)

    data.sum { |file| Array(file['messages']).size }
  end

  def parse_json_output(output, parser_name:)
    JSON.parse(output)
  rescue JSON::ParserError => e
    Rails.logger.warn("[CodeChecker] Failed to parse #{parser_name} JSON: #{e.message}")
    nil
  end
end
