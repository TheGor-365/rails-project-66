# frozen_string_literal: true

class RunRepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check_id, commit_id = nil)
    check = Check.find(check_id)
    Checks::Run.call(check: check, commit_id: commit_id)
  end
end
