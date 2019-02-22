class QuestionPolicy < AccessPolicy
  def index?
    user.present?
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
    create? 
  end

  def edit?
    create?
  end

  def destroy?
    confirm_organization &&
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