# frozen_string_literal: true

# TODO: This should never get hit because the controller authorizes against grant.
# module Grant
class Grant::StatePolicy < GrantPolicy

  def update?
    organization_admin_access? || grant_editor_access?
  end

  private

  # def state
  #   record
  # end

  def grant
    record
    # clean_record_from_collection.grant
  end

    # def confirm_organization
    #   user.present? &&
    #     clean_record_from_collection.grant.organization == user.organization
    # end
end
# end
