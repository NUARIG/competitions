# frozen_string_literal: true

class GrantSubmission::SubmissionPolicy < GrantPolicy
  attr_reader :user, :grant

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
      if user.system_admin? || check_grant_access(%i[admin editor viewer])
        @grant.submissions.includes(reviews: :criteria_reviews)
      else
        scope.where(applicant: user)
      end
    end

    def check_grant_access(role_list)
      user.id.in?(GrantPermission.where(role: role_list)
                                 .where(grant: grant)
                                 .pluck(:user_id))
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
    !grant.published? && (grant_admin_access?)
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

  def current_user_is_applicant?
    submission.applicant == user
  end

  def current_user_is_reviewer?
    submission.reviewers.include?(user)
  end
end
