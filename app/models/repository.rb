# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_many :checks, class_name: "Repository::Check", dependent: :destroy

  enumerize :language, in: %w[Ruby], predicates: true

  validates :github_id, presence: true, uniqueness: { scope: :user_id }
  validates :name, :full_name, :clone_url, :ssh_url, presence: true

  def last_check
    checks.order(created_at: :desc).first
  end
end
