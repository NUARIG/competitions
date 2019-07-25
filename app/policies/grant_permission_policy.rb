# frozen_string_literal: true
# This file never seems to be used since all permission
# policies are handled by grant policy.

class GrantPermissionPolicy < GrantPolicy
  def index?
    user.system_admin? || grant_viewer_access?
  end

  def show?
    index?
  end

  def create?
    user.system_admin? || grant_editor_access?
  end

  def new?
    create?
  end

  def edit?
    super
  end

  def update?
    super
  end

  def destroy?
    update?
  end

  private

  def grant_permission
    record
  end

  def grant
    clean_record_from_collection.grant
  end
end
