# frozen_string_literal: true

class GrantPolicy < AccessPolicy

  # Can't inherit methods inside scope, so the organization_admin_access?
  # code from AccessPolicy:6 was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  class Scope < Scope
    def resolve
      if user.organization_role == 'admin'
        scope.not_deleted.by_publish_date
      elsif (user.editable_grants.any?)
        # TODO: This needs to be ordered.
        (scope.where(state: ['published', 'completed']).not_deleted + user.editable_grants.not_deleted).uniq
      else
        scope.where(state: ['published', 'completed']).not_deleted.by_publish_date
      end
    end
  end

  def show?
    case grant.published? && grant.is_open?
    when true
      user.present?
    else
      organization_admin_access? || grant_viewer_access?
    end
  end

  def create?
    organization_admin_access? || grant_editor_access?
  end

  def new?
    create?
  end

  def update?
    organization_admin_access? || grant_editor_access?
  end

  def edit?
    update?
  end

  def destroy?
    organization_admin_access? || grant_admin_access?
  end

  # TODO: add organization_admin_access? to these.
  def grant_admin_access?
    check_grant_access(%w[admin])
  end

  def grant_editor_access?
    check_grant_access(%w[admin editor])
  end

  def grant_viewer_access?
    check_grant_access(%w[admin editor viewer])
  end

  def check_grant_access(role_list)
    user.id.in?(
      GrantPermission.where(role: role_list)
      .where(grant: grant)
      .pluck(:user_id)
    )
  end

  private

  def grant
    record
  end
end
