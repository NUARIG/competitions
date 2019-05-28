# frozen_string_literal: true

class GrantPolicy < AccessPolicy

  # Could not figure out how to inherit methods, so the
  # organization_admin_access? code from AccessPolicy:6
  # was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  class Scope < Scope
    def resolve
      if user.organization_role == 'admin' || grant_viewer_access?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end

  # def index?
  # end

  def show?
    case grant.published?
    when true
      user.organization_role == 'admin' || grant_viewer_access?
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
    # TODO: How to lock this once it has submissions. Should this be is_soft_deletable?
    grant.is_soft_deletable? && (organization_admin_access? || grant_editor_access?)
  end

  def edit?
    grant.is_soft_deletable? && (organization_admin_access? || grant_editor_access?)
  end

  def destroy?
    grant.is_soft_deletable?  && (organization_admin_access? || grant_admin_access?)
  end

  # Grant Access
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
