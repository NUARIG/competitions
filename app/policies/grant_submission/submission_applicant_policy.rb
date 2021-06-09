# frozen_string_literal: true

class GrantSubmission::SubmissionApplicantPolicy < ApplicationPolicy
  include GrantRoleAccess

  # def show?
  #   grant_viewer_access? || current_user_is_applicant? || current_user_is_reviewer?
  # end

  def create?
    grant_editor_access? || (current_user_is_applicant? && submission.draft?)
  end

  def new?
    create?
  end

  # def update?
  #   create?
  # end

  # def edit?
  #   update?
  # end

  def destroy?
    create?
  end

  private

  def submission
    record.submission
  end

  def grant
    record.submission.grant
  end

  def current_user_is_applicant?
    submission.applicants.include?(user)
  end
end
