# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.system_admin?
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
end
