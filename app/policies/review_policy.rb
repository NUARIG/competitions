# frozen_string_literal: true

class ReviewPolicy < GrantPolicy
  def index
    # TODO: scope, context, etc
    false
  end

  def new?
    false
  end

  def create?
    organization_admin_access? || grant_editor_access?
  end

  def edit?
    current_user_is_reviewer? || organization_admin_access? || grant_editor_access?
  end

  def show?
    edit?
  end

  def update?
    edit?
  end

  def destroy?
    organization_admin_access? || grant_editor_access?
  end

  private

  def review
    record
  end

  private

  def current_user_is_reviewer?
    review.reviewer == user
  end
end
