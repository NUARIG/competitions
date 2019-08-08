# frozen_string_literal: true

class ReviewPolicy < GrantPolicy
  def index?
    false
  end

  def new?
    false
  end

  def create?
    user.system_admin? || grant_editor_access?
  end

  def edit?
    current_user_is_reviewer? || user.system_admin? || grant_editor_access?
  end

  def show?
    edit?
  end

  def update?
    edit?
  end

  def destroy?
    user.system_admin? || grant_editor_access?
  end

  def opt_out?
    current_user_is_reviewer?
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
