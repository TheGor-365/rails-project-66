class User < ApplicationRecord
  has_many :repositories, dependent: :destroy

  validates :email, presence: true
end
