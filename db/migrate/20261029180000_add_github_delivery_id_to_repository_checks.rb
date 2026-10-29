# frozen_string_literal: true

class AddGithubDeliveryIdToRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :repository_checks, :github_delivery_id, :string
    add_index :repository_checks, :github_delivery_id, unique: true
  end
end
