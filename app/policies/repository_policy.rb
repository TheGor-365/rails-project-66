# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  def show?
    owner?
  end

  private

  def owner?
    user.present? && record.user_id == user.id
  end
end
