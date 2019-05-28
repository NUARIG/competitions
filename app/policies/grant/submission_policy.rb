# frozen_string_literal: true


class Grant::SubmissionPolicy < GrantPolicy

  # Could not figure out how to inherit methods, so the
  # organization_admin_access? code from AccessPolicy:6
  # was repeated.
  # https://stackoverflow.com/questions/14739640/ruby-classes-within-classes-or-modules-within-modules
  class Scope < Scope

    attr_reader :user, :grant, :scope

    def initialize(context, scope)
      @user   = context.user
      @grant  = context.grant
      @scope  = scope
    end

    def resolve
      if user.organization_role == 'admin' || grant_viewer_access?
        grant.submissions
      else
        scope.where(applicant_id == user.id)
      end
    end
  end

  # def index?
  #   organization_admin_access? || grant_viewer_access?
  # end

  def create?
    organization_admin_access? || grant_viewer_access? || submission.applicant_id == user.id
  end

  def new?
    create?
  end

  def update?
    organization_admin_access? || grant_editor_access? || submission.applicant_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    organization_admin_access? || grant_editor_access?
  end

  private

  def submission
    record
  end

  def grant
    clean_record_from_collection.grant
  end

  # def confirm_organization
  #   user.present? &&
  #     clean_record_from_collection.grant.organization == user.organization
  # end
end