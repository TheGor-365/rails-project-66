# frozen_string_literal: true

module ChecksHelper
  SHORT_SHA_LENGTH = 7

  def check_short_commit_id(check)
    commit_id = check&.commit_id
    return if commit_id.blank?

    commit_id.to_s[0, SHORT_SHA_LENGTH]
  end

  def check_github_commit_url(check)
    repo_full_name = check&.repository&.full_name
    short = check_short_commit_id(check)
    return if repo_full_name.blank? || short.blank?

    "https://github.com/#{repo_full_name}/commit/#{short}"
  end

  def check_github_file_url(check, file_path, line: nil)
    path = file_path.to_s
    return if path.blank? || path.start_with?('/', '\\')
    return if path.split('/').any? { |part| %w[. ..].include?(part) }

    sha = check.commit_id.to_s
    return unless sha.match?(/\A[0-9a-f]{7,40}\z/i)
    return if check.repository.full_name.blank?

    encoded_path = path.split('/').map { |part| ERB::Util.url_encode(part) }.join('/')
    url = "https://github.com/#{check.repository.full_name}/blob/#{sha}/#{encoded_path}"
    line.to_i.positive? ? "#{url}#L#{line.to_i}" : url
  end

  def check_status_text(check)
    return check.aasm.human_state unless check.finished?

    t("checks.result_status.#{check.status}", default: check.status.to_s)
  end
end
