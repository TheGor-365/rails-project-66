# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM
  include Repository::CheckOutputParsing

  belongs_to :repository

  aasm column: :aasm_state do
    state :pending, initial: true
    state :running
    state :finished

    event :run_check do
      transitions from: :pending, to: :running
    end

    event :finish do
      transitions from: :running, to: :finished
    end
  end

  AASM_LABELS = {
    'pending'  => 'Ожидает',
    'running'  => 'Выполняется',
    'finished' => 'Завершена'
  }.freeze

  RESULT_LABELS = {
    'pending' => 'Ожидает',
    'passed'  => 'Успешно',
    'failed'  => 'С ошибками'
  }.freeze

  SHORT_SHA_LENGTH = 7

  def human_status
    return AASM_LABELS[aasm_state] || aasm_state unless finished?

    RESULT_LABELS[status] || status
  end

  def short_commit_id
    return if commit_id.blank?

    commit_id[0, SHORT_SHA_LENGTH]
  end

  def github_commit_url
    return if repository.blank? || repository.full_name.blank? || short_commit_id.blank?

    "https://github.com/#{repository.full_name}/commit/#{short_commit_id}"
  end

  def perform!(commit_id: nil)
    run_check! if may_run_check?

    result, error = run_code_checker(commit_id)
    return handle_failed_check_run!(commit_id, error) if error

    run_data = persist_successful_check_run!(result, fallback_commit_id: commit_id)
    finalize_check!(passed: run_data[:passed], offenses_count: run_data[:offenses_count])

    self
  end

  private

  def run_code_checker(commit_id)
    code_checker = ApplicationContainer[:code_checker]
    [ code_checker.run(repository: repository, commit_id: commit_id), nil ]
  rescue StandardError => e
    [ nil, e ]
  end

  def handle_failed_check_run!(commit_id, error)
    update!(
      commit_id: commit_id,
      status:    'failed',
      passed:    false,
      output:    error.full_message(highlight: false, order: :top)
    )

    finalize_check!(passed: false, offenses_count: nil)

    self
  end

  def persist_successful_check_run!(result, fallback_commit_id:)
    offenses_count = result.offenses_count.to_i
    passed = result.success? && offenses_count.zero?
    final_status = passed ? 'passed' : 'failed'
    stored_commit_id = result.commit_id.presence || fallback_commit_id

    update!(
      commit_id:        stored_commit_id,
      output:           result.output,
      violations_count: offenses_count,
      passed:           passed,
      status:           final_status
    )

    { passed:, offenses_count: }
  end

  def finalize_check!(passed:, offenses_count:)
    finish! if may_finish?
    notify_if_failed(offenses_count) unless passed
  end

  def notify_if_failed(offenses_count)
    failed = offenses_count.nil? || offenses_count.positive?
    return unless failed

    CheckMailer.check_report(self).deliver_now
  rescue StandardError => e
    Rails.logger.error(
      "[CheckMailer] Failed to send report for check_id=#{id}: #{e.class}: #{e.message}"
    )
  end
end
