class GrantSubmission::SubmissionPolicy < ApplicationPolicy
  include GrantRoleAccess
  include GrantSubmission::SubmissionRoleAccess

  def initialize(context, record)
    @user   = context.user
    @grant  = context.grant
    @record = record
  end

  def show?
    grant_viewer_access? || current_user_is_applicant? || current_user_is_reviewer?
  end

  def create?
    (user.present? && @grant.accepting_submissions?) || grant_viewer_access?
  end

  def new?
    create?
  end

  def update?
    (grant_editor_access? || current_user_is_applicant?) && submission.draft?
  end

  def edit?
    update?
  end

  def destroy?
    grant_admin_access? && (submission.submitter.in?(grant.administrators) || !grant.published?)
  end

  def unsubmit?
    grant_editor_access?
  end

  def award?
    grant_editor_access?  || user.system_admin?
  end

  private

  def submission
    record
  end

  def grant
    record.grant
  end
end
