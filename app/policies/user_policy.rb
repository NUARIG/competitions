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
        scope.all.order_by_last_name
      else
        scope.where(id: user.id)
      end
    end
  end

  def update?
    user.system_admin? || record == user
  end

  def edit?
    user.system_admin?
  end

  def profile?
    record == user
  end

  private

  def current_user
  end

end
