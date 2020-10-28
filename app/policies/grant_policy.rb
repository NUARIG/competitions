# frozen_string_literal: true

class GrantPolicy < ApplicationPolicy
  include GrantRoleAccess

  class Scope < Scope
    def resolve
      if user.system_admin?
        scope.kept.by_publish_date
      else
        scope.public_grants.by_publish_date
      end
    end
  end

  def show?
    if grant.published? && DateTime.now.between?(grant.publish_date.beginning_of_day, grant.submission_close_date.end_of_day)
      true
    else
      user.present? && (grant_viewer_access? || user_is_grant_reviewer?)
    end
  end

  def create?
     user.present? && user.system_admin? || user.grant_creator?
  end

  def new?
    user.present? && create?
  end

  def update?
    user.present? && grant_editor_access?
  end

  def edit?
    user.present? && grant_viewer_access?
  end

  def destroy?
    user.present? && grant_admin_access?
  end

  def duplicate?
    user.system_admin? || (user.grant_creator? && grant_editor_access?)
  end


  private

  def grant
    record
  end
end
