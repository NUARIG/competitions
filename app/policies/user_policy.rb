# frozen_string_literal: true

class UserPolicy < AccessPolicy

  # Could not figure out how to inherit methods, so the
  # organization_admin_access? code from AccessPolicy:6
  # was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.organization_role == 'admin'
        scope.all
      else
        scope.where(id: user.id)
        # scope.none
      end
    end
  end


  # def index?
  #   organization_admin_access?
  # end

  def show?
    organization_admin_access? || record == user
  end

  def update?
    organization_admin_access? || record == user
  end

  def edit?
    update?
  end
end
