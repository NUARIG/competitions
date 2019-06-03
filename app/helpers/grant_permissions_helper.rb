# frozen_string_literal: true

module GrantPermissionsHelper
  def grant_permission_role_select_options
    GrantPermission.roles.keys.to_a
  end
end
