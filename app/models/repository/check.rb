# frozen_string_literal: true

class Repository::Check < ApplicationRecord
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
end
