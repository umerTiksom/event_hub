class UserPolicy < ApplicationPolicy


    def index?
      user.present? && user.admin?
    end

    def show?
      user.present? &&
        (user.admin? || record.id == user.id)
    end

    def update?
      user.present? && user.admin?
    end

    def destroy?
      user.present? && user.admin?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        user.admin? ? scope.all : scope.where(id: user.id)
      end
    end
end
