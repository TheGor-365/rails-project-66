# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  belongs_to :repository

  include AASM

  aasm column: :status do
    state :pending, initial: true
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
    "pending" => "Ожидает",
    "running" => "Выполняется",
    "finished" => "Завершена",
    "failed" => "Ошибка"
  }.freeze

  def human_status
    STATUS_LABELS[status] || status
  end

  # Основной сценарий проверки
  def perform!
    run_check!

    code_checker = ApplicationContainer[:code_checker]
    result = code_checker.run(repository: repository, commit_id: commit_id)

    update!(
      commit_id: result.commit_id,
      output: result.output,
      violations_count: result.offenses_count,
      passed: result.success?
    )

    if result.success?
      complete_success!
    else
      complete_failure!
    end
  end
end
