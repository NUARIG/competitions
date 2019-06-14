# frozen_string_literal: true


class GrantSubmission::SubmissionPolicy < GrantPolicy

  # Can't inherit methods inside scope, so the organization_admin_access?
  # code from AccessPolicy:6 was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  attr_reader :user, :grant, :scope

  def initialize(context, scope)
    @user   = context.user
    @grant  = context.grant
    @scope  = scope
  end

  class Scope < Scope

    attr_reader :user, :grant, :scope

    def initialize(context, scope)
      @user   = context.user
      @grant  = context.grant
      @scope  = scope
    end

    def resolve
      if user.organization_role == 'admin' || grant_viewer_access?
        @grant.submissions
      else
        scope.where(applicant_id == user.id)
      end
    end
  end

  def show?
    organization_admin_access? || grant_editor_access? || current_user_is_applicant?
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
    !@grant.published? && (organization_admin_access? || grant_editor_access?)
  end

  private

  def submission
    record
  end

  def grant
    @grant
  end

  def current_user_is_applicant?
    submission.applicant_id == user.id
  end
end
