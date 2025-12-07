class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user

  enumerize :language, in: %w[Ruby], predicates: true, scope: true

  validates :github_id, presence: true, uniqueness: { scope: :user_id }
  validates :name, :full_name, presence: true
end
