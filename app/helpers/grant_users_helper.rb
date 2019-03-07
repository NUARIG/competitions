module GrantUsersHelper
	def grant_user_grant_role_select_options
		GrantUser.grant_roles.keys.to_a
	end
end
