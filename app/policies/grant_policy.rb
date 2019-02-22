class GrantPolicy < AccessPolicy
	def index?
		organization_basic_access?
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
  	create? 
  end

  def edit?
    create?
  end

  def destroy?
  	organization_admin_access?
  end

	private
		def grant
			record
		end
end