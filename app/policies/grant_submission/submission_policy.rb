# frozen_string_literal: true

class GrantSubmission::SubmissionPolicy < ApplicationPolicy
  attr_reader :user, :grant
  include GrantRoleAccess

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
        GrantSubmission::Submission.includes(:submitter, :reviews).where(grant_id: @grant.id)
      else
        scope.where(submitter: user)
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
    grant_admin_access? && (submission.submitter.in?(@grant.administrators) || !grant.published?)
  end

  def unsubmit?
    grant_editor_access?
  end

  private

  def submission
    record
  end

  def grant
    @grant
  end

  # def current_user_is_submitter?
  #   submission.submitter == user
  # end

  def current_user_is_applicant?
    submission.applicants.include?(user)
  end

  def current_user_is_reviewer?
    submission.reviewers.include?(user)
  end
end
