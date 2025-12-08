# frozen_string_literal: true

class CreateRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    create_table :repository_checks do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :commit_id
      t.boolean :passed
      t.integer :violations_count
      t.text :output

      t.timestamps
    end
  end
end
