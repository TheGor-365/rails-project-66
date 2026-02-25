# frozen_string_literal: true

class CodeChecker
  module Support
    private

    def sanitize_clone_url(raw_url)
      url = raw_url.to_s.strip

      return url if url.start_with?('https://github.com/')
      return url if url.start_with?('git@github.com:')
      return url if github_https_url?(url)

      raise ArgumentError, 'Unsupported clone URL (only GitHub HTTPS/SSH URLs are allowed)'
    end

    def github_https_url?(url)
      uri = URI.parse(url)
      %w[http https].include?(uri.scheme) && uri.host == 'github.com'
    rescue URI::InvalidURIError => e
      Rails.logger.warn("[CodeChecker] Invalid clone URL: #{e.message}")
      false
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
end
