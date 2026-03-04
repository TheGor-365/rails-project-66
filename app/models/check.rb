# frozen_string_literal: true

class Check < ApplicationRecord
  self.table_name = 'repository_checks'

  include AASM
  include Repository::CheckOutputParsing

  belongs_to :repository

  aasm column: :aasm_state do
    state :pending, initial: true
    state :running
    state :finished
    state :failed

    event :run_check do
      transitions from: :pending, to: :running
    end

    event :finish do
      transitions from: :running, to: :finished
    end

    event :fail do
      transitions from: :running, to: :failed
    end
  end

  SHORT_SHA_LENGTH = 7

  def human_status
    return I18n.t("checks.aasm_state.#{aasm_state}", default: aasm_state.to_s) unless finished?

    I18n.t("checks.result_status.#{status}", default: status.to_s)
  end

  def short_commit_id
    return if commit_id.blank?

    commit_id[0, SHORT_SHA_LENGTH]
  end

  def github_commit_url
    return if repository.blank? || repository.full_name.blank? || short_commit_id.blank?

    "https://github.com/#{repository.full_name}/commit/#{short_commit_id}"
  end
end
