# frozen_string_literal: true

# TODO: This should never get hit because the controller authorizes against grant.
class Grant::DuplicatePolicy < GrantPolicy

  def create?
    organization_admin_access? || grant_editor_access?
  end

  def new?
    create?
  end

  private

  def grant
    record
  end
end
