# frozen_string_literal: true

class GrantPolicy < AccessPolicy

  # Could not figure out how to inherit methods, so the
  # organization_admin_access? code from AccessPolicy:6
  # was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  class Scope < Scope
    def resolve
      if user.organization_role == 'admin'
        scope.not_deleted.by_publish_date.with_organization
      elsif (user.grants.any?)
        user.grants.not_deleted
      else
        scope.not_deleted.where(published: true)
      end
    end
  end

  # def index?
  # end

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

  #
  # def apply?
  #   (organization_admin_access? || grant_editor_access?) || (user.present? && grant.accepting_submissions?)
  # end

  #This needs to be worked out?????
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
