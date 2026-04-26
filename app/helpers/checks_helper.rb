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

  def check_status_text(check)
    return check.aasm.human_state unless check.finished?

    t("checks.result_status.#{check.status}", default: check.status.to_s)
  end
end
