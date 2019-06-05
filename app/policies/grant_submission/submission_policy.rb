# frozen_string_literal: true


class GrantSubmission::SubmissionPolicy < GrantPolicy

  # Could not figure out how to inherit methods, so the
  # organization_admin_access? code from AccessPolicy:6
  # was repeated.
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


    # def resolve
    #   if user.organization_role == 'admin'
    #     scope.not_deleted.by_publish_date.with_organization
    #   elsif (user.grants.any?)
    #     user.grants.not_deleted
    #   else
    #     scope.not_deleted.where(published: true)
    #   end
    # end


  end

  # def index?
  #   organization_admin_access? || grant_viewer_access?
  # end

  def create?
    (@user.organization_role =='admin') || (user.present? && @grant.accepting_submissions?)
    # @user.organization_role =='admin' ||
    # organization_admin_access? || grant_viewer_access? || submission.applicant_id == user.id
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

  # def confirm_organization
  #   user.present? &&
  #     clean_record_from_collection.grant.organization == user.organization
# end
end