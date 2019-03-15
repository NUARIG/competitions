# frozen_string_literal: true

class UserPolicy < AccessPolicy
  def index?
    organization_admin_access?
  end

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
