# frozen_string_literal: true

class GrantPermissionPolicy < GrantPolicy

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
