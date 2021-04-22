# frozen_string_literal: true

class GrantReviewersController < ApplicationController
  before_action     :set_grant

  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    authorize @grant, :grant_editor_access?

    @grant_reviewers        = @grant.grant_reviewers.includes(:reviewer).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
    @unassigned_submissions = @grant.submissions.submitted.to_be_assigned(@grant.max_reviewers_per_submission).includes(:applicant).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
  end

  def create
    authorize @grant, :edit?

    email   = grant_reviewer_params[:reviewer_email].downcase.strip
    reviewer = User.find_by(email: email)

    if reviewer.nil?
      flash[:alert] = "Could not find a user with the email: #{email}. #{helpers.link_to 'Invite them to be a reviewer', invite_grant_reviewers_path(@grant, email: email), method: :post, data: { confirm: "An email will be sent to #{email}. You will be notified when they accept or opt out."} }"
    else
      grant_reviewer = GrantReviewer.create(grant: @grant, reviewer: reviewer)
      if grant_reviewer.errors.none?
        flash[:success] = "Added #{helpers.full_name(grant_reviewer.reviewer)} as reviewer."
      else
        flash[:alert]   = grant_reviewer.errors.full_messages
      end

    end

    redirect_to grant_reviewers_path(@grant)
  end

  def destroy
    authorize @grant, :edit?

    grant_reviewer = GrantReviewer.find(params[:id])

    if grant_reviewer.nil?
      flash[:alert] = 'Reviewer could not be found.'
    else
      result = GrantReviewerServices::DeleteReviewer.call(grant_reviewer: grant_reviewer)
      if result.success?
        flash[:success] = result.messages
      else
        flash[:alert] = result.messages
      end
    end

    redirect_to grant_reviewers_path(@grant)
  end

  private

  def set_grant
    @grant = Grant.kept.friendly.find(params[:grant_id])
  end

  def grant_reviewer_params
    params.require(:grant_reviewer).permit(:id, :reviewer_email)
  end
end
