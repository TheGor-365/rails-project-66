# frozen_string_literal: true

module Repository::CheckOutputParsing
  def parsed_output
    return if output.blank?

    JSON.parse(output)
  rescue JSON::ParserError
    nil
  end

  def offenses_by_file
    data = parsed_output
    return [] if data.blank?
    return rubocop_offenses_by_file(data) if rubocop_payload?(data)
    return eslint_offenses_by_file(data) if data.is_a?(Array)

    []
  end

  private

  def normalize_repository_file_path(path)
    # RuboCop/ESLint return absolute checkout paths. Strip only our generated
    # checkout directory so historical results can link to GitHub files.
    path.to_s.sub(%r{\A/(?:[^/]+/)*repo-\d+-[0-9a-f]{8}/}, '')
  end

  def rubocop_payload?(data)
    data.is_a?(Hash) && data['files'].is_a?(Array)
  end

  def rubocop_offenses_by_file(data)
    data['files'].filter_map do |file|
      offenses = rubocop_file_offenses(file)
      { path: normalize_repository_file_path(file['path']), offenses: } if offenses.any?
    end
  end

  def rubocop_file_offenses(file)
    Array(file['offenses']).map do |offense|
      {
        message: offense['message'],
        rule: offense['cop_name'],
        line: offense.dig('location', 'line'),
        column: offense.dig('location', 'column')
      }
    end
  end

  def eslint_offenses_by_file(data)
    data.filter_map do |file|
      offenses = eslint_file_offenses(file)
      { path: normalize_repository_file_path(file['filePath'] || file['path']), offenses: } if offenses.any?
    end
  end

  def eslint_file_offenses(file)
    Array(file['messages']).map do |offense|
      {
        message: offense['message'],
        rule: offense['ruleId'],
        line: offense['line'],
        column: offense['column']
      }
    end
  end
end
