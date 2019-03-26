# frozen_string_literal: true

class SubmissionPolicy < AccessPolicy
  def index?
    organization_admin_access?
  end

  def show?
    organization_admin_access? || submission.user == user
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    show?
  end

  def edit?
    show?
  end

  def destroy?
    show?
  end

  private
  def submission
    record
  end
end
