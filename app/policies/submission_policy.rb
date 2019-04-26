# frozen_string_literal: true

class SubmissionPolicy < GrantPolicy
  def show?
    grant_viewer_access? || submission.user == user
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    grant_editor_access? || submission.user == user
  end

  def edit?
    update?
  end

  def destroy?
    grant_admin_access? || submission.user == user
  end

  private
  def submission
    record
  end

  def grant
    submission.grant
  end

end
