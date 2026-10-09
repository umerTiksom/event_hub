class RegistrationPolicy < ApplicationPolicy

  def index?
      user.present? &&
        (user.admin? || record.user_id == user.id)
  end

  def create?
      user.present? && user.user?
  end

  def destroy?
      user.present? &&
        (user.admin? || record.user_id == user.id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
