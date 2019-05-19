class Submission::FormPolicy < AccessPolicy
  attr_reader :user, :record


  class Scope < Scope
    def resolve
      # if user.admin?
      #   scope.all
      # else
      #   scope.where(published: true)
      # end
      scope.all
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    true
  end

  def edit?
    update?
  end

  def destroy?
    true
  end
end
