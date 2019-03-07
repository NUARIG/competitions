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
    user.id.in?(
      GrantUser.where(grant_role: (%w[admin]))
      .where(grant: grant)
      .pluck(:user_id)
      )
  end

  def grant_editor_access?
    user.id.in?(
      GrantUser.where(grant_role: (%w[admin editor]))
      .where(grant: grant)
      .pluck(:user_id)
      )
  end

  def grant_viewer_access?
    user.id.in?(
      GrantUser.where(grant_role: (%w[admin editor viewer]))
      .where(grant: grant)
      .pluck(:user_id)
      )
  end


	private
		def grant
			record
		end
end