class GrantCreatorRequestPolicy < ApplicationPolicy
  def index
    user.system_admin?
  end

  def new?
    user.present?
  end

  def create?
    new?
  end

  def edit?
    user_is_requester? || user.system_admin?
  end

  def show?
    user_is_requester? || user.system_admin?
  end

  def update?
    user_is_requester?
  end

  def destroy?
    user_is_requester?
  end

  def review?
    user.system_admin?
  end

  private

  def user_is_requester?
    user == grant_creator_request.requester
  end

  def grant_creator_request
    record
  end
end
