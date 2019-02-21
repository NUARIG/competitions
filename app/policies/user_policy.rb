class UserPolicy < AccessPolicy
	def index?
		organization_viewer_access
  end

  def show?
  	organization_viewer_access || record == user
  end

  def create?
  	false
  end

  def new?
    create?
  end

  def update?
  	organization_admin_access || record == user
  end

  def edit?
    update?
  end

  def destroy?
  	false
  end

	private
		def user
			record
		end
end
end