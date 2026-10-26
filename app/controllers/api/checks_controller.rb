# frozen_string_literal: true

require 'openssl'

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.raw_post
    return head :unauthorized unless valid_github_signature?(payload)
    return head :no_content unless request.headers['X-GitHub-Event'] == 'push'

    data = JSON.parse(payload)
    github_repo_id = data.dig('repository', 'id')
    commit_id = data['after']

    repository = Repository.find_by!(github_id: github_repo_id)

    check = repository.checks.create!(status: :pending)
    RunRepositoryCheckJob.perform_later(check.id, commit_id)

    head :accepted
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue JSON::ParserError
    head :unprocessable_content
  end

  private

  def valid_github_signature?(payload)
    secret = ENV.fetch('GITHUB_WEBHOOK_SECRET', '').to_s
    return false if secret.blank?

    signature = request.headers['X-Hub-Signature-256'].to_s
    expected = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, payload)}"

    signature.bytesize == expected.bytesize &&
      ActiveSupport::SecurityUtils.secure_compare(signature, expected)
  end
end
