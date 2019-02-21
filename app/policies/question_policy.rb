class QuestionPolicy < AccessPolicy
  def index?
    organization_basic_access?
  end

  def show?
    index?
  end

  def create?
    confirm_organization &&
    can_create?
  end

  def new?
    can_create?
  end

  def update?
    confirm_organization &&
    can_create? 
  end

  def edit?
    update?
  end

  def destroy?
    confirm_organization
    user.organization_role == 'admin'
  end

	private
		def question
			record
		end

    def confirm_organization
      user.present? && 
      clean_record_from_collection.grant.organization == user.organization 
    end
end