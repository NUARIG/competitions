# frozen_string_literal: true

class GrantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.system_admin?
        scope.not_deleted.by_publish_date
      else
        scope.public_grants.by_publish_date
      end
    end
  end

  def show?
    if grant.published? && DateTime.now.between?(grant.publish_date, grant.submission_close_date)
      true
    else
      user.present? && grant_viewer_access? || user_is_grant_reviewer?
    end
  end

  def create?
    user.system_admin? || user.grant_creator?
  end

  def new?
    create?
  end

  def update?
    user.system_admin? || grant_editor_access?
  end

  def edit?
    update?
  end

  def destroy?
    user.system_admin? || grant_admin_access?
  end

  def duplicate?
    user.system_admin? || (user.grant_creator? && grant_editor_access?)
  end

  def grant_admin_access?
    check_grant_access(%w[admin])
  end

  def grant_editor_access?
    check_grant_access(%w[admin editor])
  end

  def grant_viewer_access?
    user.system_admin? || check_grant_access(%w[admin editor viewer])
  end

  def check_grant_access(role_list)
    user.id.in?(GrantPermission.where(role: role_list)
                               .where(grant: grant)
                               .pluck(:user_id))
  end

  private

  def grant
    record
  end

  def user
    @user
  end

  def user_is_grant_reviewer?
    grant.reviewers.include?(user)
  end
end
