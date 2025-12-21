# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  belongs_to :repository

  include AASM

  aasm column: :status do
    state :pending,  initial: true
    state :running
    state :finished
    state :failed

    event :run_check do
      transitions from: :pending, to: :running
    end

    event :complete_success do
      transitions from: :running, to: :finished
    end

    event :complete_failure do
      transitions from: :running, to: :failed
    end
  end

  STATUS_LABELS = {
    'pending'  => 'Ожидает',
    'running'  => 'Выполняется',
    'finished' => 'Завершена',
    'failed'   => 'Ошибка'
  }.freeze

  SHORT_SHA_LENGTH = 7

  def human_status
    STATUS_LABELS[status] || status
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
    update!(status: :running)

    code_checker = ApplicationContainer[:code_checker]

    begin
      result = code_checker.run(repository: repository, commit_id: commit_id)
    rescue StandardError => e
      update!(
        status: :failed,
        passed: false,
        output: e.full_message(highlight: false, order: :top)
      )

      notify_if_failed(nil)
      return self
    end

    offenses_count = result.offenses_count.to_i
    success        = result.success?

    update!(
      commit_id:        result.commit_id,
      output:           result.output,
      violations_count: offenses_count,
      passed:           success,
      status:           success ? :finished : :failed
    )

    notify_if_failed(offenses_count)

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
