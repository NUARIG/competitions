# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.system_admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end

  def show?
    user.system_admin? || record == user
  end

  def update?
    user.system_admin? || record == user
  end

  def edit?
    update?
  end

  def profile?
    record == user
  end

  private

  def current_user
  end

end
