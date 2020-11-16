module GrantRoleAccess
  GRANT_ACCESS = { 'viewer' =>  1,
                   'editor' =>  2,
                   'admin'  =>  3 }
  GRANT_ACCESS.default = -1
  GRANT_ACCESS.freeze

  def grant_admin_access?
    GRANT_ACCESS['admin'] <= GRANT_ACCESS[user.get_role_by_grant(grant: grant)]
  end

  def grant_editor_access?
    GRANT_ACCESS['editor'] <= GRANT_ACCESS[user.get_role_by_grant(grant: grant)]
  end

  def grant_viewer_access?
    GRANT_ACCESS['viewer'] <= GRANT_ACCESS[user.get_role_by_grant(grant: grant)]
  end

  def user_is_grant_reviewer?
    GrantReviewer.find_by(reviewer: user, grant: grant).present?
  end
end
