# frozen_string_literal: true

class GrantSubmission::SubmissionPolicy < GrantPolicy

  # Can't inherit methods inside scope, so the organization_admin_access?
  # code from AccessPolicy:6 was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
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
      if user.organization_role == 'admin' || check_grant_access(%i[admin editor viewer])
        @grant.submissions
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
    organization_admin_access? || grant_editor_access? || current_user_is_applicant? || current_user_is_reviewer?
  end

  def create?
    organization_admin_access? || (user.present? && @grant.accepting_submissions?)
  end

  def new?
    create?
  end

  def update?
    organization_admin_access? || grant_editor_access? || current_user_is_applicant?
  end

  def edit?
    update?
  end

  def destroy?
    # TODO: Admin and g.unpublished
    !grant.published? && (organization_admin_access? || grant_editor_access?)
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
