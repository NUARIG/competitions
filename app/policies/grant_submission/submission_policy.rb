# frozen_string_literal: true

class GrantSubmission::SubmissionPolicy < ApplicationPolicy
  include GrantRoleAccess
  include GrantSubmission::SubmissionRoleAccess

  def initialize(context, record)
    @user   = context.user
    @grant  = context.grant
    @record = record
  end

  class Scope < Scope

    attr_reader :user, :grant, :scope

    def initialize(context, scope)
      @user   = context.user
      @grant  = context.grant
      @scope  = scope
    end

    def resolve
      if user.in?(@grant.administrators) || user.system_admin?
        GrantSubmission::Submission.kept.includes(:reviews, :applicants).where(grant_id: @grant.id)
      else
        GrantSubmission::Submission.kept.includes(:applicants).where(users: { id: user.id })
      end
    end
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

  private

  def submission
    record
  end

  def grant
    record.grant
  end
end
