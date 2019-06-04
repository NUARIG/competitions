# frozen_string_literal: true

module WithGrantRoles
  extend ActiveSupport::Concern

  def current_user_grant_permission
    grant_permission  = grant_role_by_user(@grant, current_user)
    organization_role = current_user.organization_role

    return 'admin' if grant_permission == 'admin' || organization_role == 'admin'

    grant_permission.present? ? grant_permission.grant_role : organization_role
  end

  def grant_role_by_user(grant, user)
    # TODO: Handle grant_role == nil
    GrantUser.find_by(grant: grant, user: user)
  end
end
