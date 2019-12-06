# frozen_string_literal: true

class ReviewPolicy < GrantPolicy
  def index?
    false
  end

  def new?
    false
  end

  def create?
    grant_editor_access?
  end

  def edit?
    current_user_is_reviewer? || grant_editor_access?
  end

  def show?
    current_user_is_reviewer? || grant_viewer_access?
  end

  def update?
    edit?
  end

  def destroy?
    grant_editor_access?
  end

  def opt_out?
    current_user_is_reviewer?
  end

  private

  def review
    record
  end

  def grant
    record.grant
  end

  def current_user_is_reviewer?
    review.reviewer == user
  end
end
