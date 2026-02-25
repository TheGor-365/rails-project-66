# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  belongs_to :repository

  include AASM

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

    code_checker = ApplicationContainer[:code_checker]

    begin
      result = code_checker.run(repository: repository, commit_id: commit_id)
    rescue StandardError => e
      update!(
        commit_id: commit_id,
        status:    'failed',
        passed:    false,
        output:    e.full_message(highlight: false, order: :top)
      )
      finish! if may_finish?
      notify_if_failed(nil)
      return self
    end

    offenses_count = result.offenses_count.to_i
    ran_ok = result.success?

    passed = ran_ok && offenses_count.zero?
    final_status = passed ? 'passed' : 'failed'
    stored_commit_id = result.commit_id.presence || commit_id

    update!(
      commit_id:        stored_commit_id,
      output:           result.output,
      violations_count: offenses_count,
      passed:           passed,
      status:           final_status
    )

    finish! if may_finish?
    notify_if_failed(offenses_count) unless passed

    self
  end

  def parsed_output
    return if output.blank?

    JSON.parse(output)
  rescue JSON::ParserError
    nil
  end

  def offenses_by_file
    data = parsed_output
    return [] if data.blank?

    if data.is_a?(Hash) && data['files'].is_a?(Array)
      return data['files'].map do |file|
        path     = file['path']
        offenses = Array(file['offenses']).map do |offense|
          {
            message: offense['message'],
            rule:    offense['cop_name'],
            line:    offense.dig('location', 'line'),
            column:  offense.dig('location', 'column')
          }
        end

        { path:, offenses: }
      end
    end

    if data.is_a?(Array)
      return data.map do |file|
        path     = file['filePath'] || file['path']
        offenses = Array(file['messages']).map do |offense|
          {
            message: offense['message'],
            rule:    offense['ruleId'],
            line:    offense['line'],
            column:  offense['column']
          }
        end

        { path:, offenses: }
      end
    end

    []
  end

  private

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
