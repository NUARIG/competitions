# frozen_string_literal: true

class Grant::GrantPermissionPolicy < GrantPolicy

  # Could not figure out how to inherit methods, so the
  # organization_admin_access? code from AccessPolicy:6
  # was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  class Scope < Scope

    attr_reader :user, :grant, :scope

    def initialize(context, scope)
      @user   = context.user
      @grant  = context.grant
      @scope  = scope
    end

    def resolve
      if user.organization_role == 'admin' || grant_viewer_access?
        grant.grant_permissions
      else
        scope.none
      end
    end
  end

  # def index?
  #   organization_admin_access? || grant_viewer_access?
  # end

  def show?
    index?
  end

  def update?
    organization_admin_access? || grant_editor_access?
  end

  def edit?
    update?
  end

  def destroy?
    # TODO: Is this the right policy
    update?
  end


  private

  def grant_permission
    record
  end

  def grant
    clean_record_from_collection.grant
  end

  # def confirm_organization
  #   user.present? &&
  #     clean_record_from_collection.grant.organization == user.organization
  # end
end
