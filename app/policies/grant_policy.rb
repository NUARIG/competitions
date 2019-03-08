class GrantPolicy < AccessPolicy
	def index?
		user.present?
  end

  def show?
  	index?
  end

  def create?
    organization_editor_access?
  end

  def new?
    can_create?
  end

  def update?
  	organization_editor_access? || grant_editor_access?
  end

  def edit?
    update?
  end

  def destroy?
  	organization_admin_access? || grant_admin_access?
  end

  # Grant Access
  def grant_admin_access?
    check_grant_access(%w[admin])
  end

  def grant_editor_access?
    check_grant_access(%w[admin editor])
  end

  def grant_viewer_access?
    check_grant_access(%w[admin editor viewer])
  end

  def check_grant_access(role_list)
    user.id.in?(
      GrantUser.where(grant_role: role_list)
      .where(grant: grant)
      .pluck(:user_id)
      )
  end


	private
		def grant
			record
		end
end