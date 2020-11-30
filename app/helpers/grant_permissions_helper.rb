# frozen_string_literal: true

module GrantPermissionsHelper
  def grant_permission_role_select_options
    GrantPermission::ROLES.values.map{ |permission| [permission.capitalize, permission]}
  end
end
