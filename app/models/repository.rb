# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_many :checks, dependent: :destroy

  enumerize :language, in: %w[ruby javascript], predicates: true

  def self.supported_languages
    language.values.map(&:to_s)
  end

  def self.supported_language?(language)
    supported_languages.include?(language.to_s.downcase)
  end

  validates :github_id, presence: true, uniqueness: { scope: :user_id }
  validates :name, :full_name, :clone_url, :ssh_url, presence: true

  def language=(value)
    super(value.to_s.downcase.presence)
  end

  def last_check
    checks.order(created_at: :desc).first
  end
end
