
# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present? && %w[admin organizer].include?(user.role)
  end

  def update?
    user.present? &&
      (user.role == "admin" || record.user_id == user.id)
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
