# frozen_string_literal: true

class AddAasmStateToRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :repository_checks, :aasm_state, :string, null: false, default: "pending"
    add_index  :repository_checks, :aasm_state
  end
end
