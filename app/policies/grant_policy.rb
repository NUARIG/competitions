# frozen_string_literal: true

class GrantPolicy < ApplicationPolicy
  GRANT_ACCESS = { 'viewer' =>  1,
                   'editor' =>  2,
                   'admin'  =>  3 }
  GRANT_ACCESS.default = -1
  GRANT_ACCESS.freeze

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
    user.system_admin? || user.grant_creator?
  end

  def new?
    create?
  end

  def update?
    grant_editor_access?
  end

  def edit?
    grant_viewer_access?
  end

  def destroy?
    grant_admin_access?
  end

  def duplicate?
    user.system_admin? || (user.grant_creator? && grant_editor_access?)
  end

  def grant_admin_access?
    GRANT_ACCESS['admin'] <= GRANT_ACCESS[user.get_role_by_grant(grant: grant)]
  end

  def grant_editor_access?
    GRANT_ACCESS['editor'] <= GRANT_ACCESS[user.get_role_by_grant(grant: grant)]
  end

  def grant_viewer_access?
    GRANT_ACCESS['viewer'] <= GRANT_ACCESS[user.get_role_by_grant(grant: grant)]
  end

  private

  def grant
    record
  end

  def user_is_grant_reviewer?
    GrantReviewer.find_by(reviewer: user, grant: grant).present?
  end
end
