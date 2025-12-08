# frozen_string_literal: true

class Api::ChecksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.raw_post

    data = JSON.parse(payload)

    github_repo_id = data.dig("repository", "id")
    commit_id      = data["after"]

    repository = Repository.find_by!(github_id: github_repo_id)

    check = repository.checks.create!(status: :pending)
    check.perform!(commit_id: commit_id)

    head :ok
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue JSON::ParserError
    head :unprocessable_entity
  end
end
