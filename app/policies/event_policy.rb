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

    return false unless user.present?
    user.admin? || (user.role?(:organizer) || user.role?(:user))
  end

  def destroy?
    update
  end

  class Scope < ApplicationPolicy::Scope
    def resolve?
      scope.all
    end
  end
end
