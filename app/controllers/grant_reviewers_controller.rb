# frozen_string_literal: true

class GrantReviewersController < ApplicationController
  before_action :set_grant
  before_action :authorize_grant_editor, only: %i[create destroy]
  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    flash.keep

    @reviewers = @grant.reviewers
    @reviews = @grant.reviews
    authorize @grant, :grant_editor_access?

    @grant_reviewers = @grant.grant_reviewers.includes(:reviewer).order("#{User.table_name}.last_name,
                                                                         #{User.table_name}.first_name")
  end

  def create
    email    = grant_reviewer_params[:reviewer_email].downcase.strip
    reviewer = User.find_by(email: email)

    if email.blank?
      flash[:alert] = 'Please enter a valid email address.'
    elsif reviewer.nil?
      flash[:alert] =
        "Could not find a user with the email: #{email}. #{helpers.link_to 'Invite them to be a reviewer',
                                                                           invite_grant_reviewers_path(@grant, email: email), method: :post, data: { turbo: false, confirm: "An email will be sent to #{email}. You will be notified when they accept or opt out." }, turbo: false}"
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
    @grant_reviewer = GrantReviewer.find_by_id(params[:id])
    @result = GrantReviewerServices::DeleteReviewer.call(grant_reviewer: @grant_reviewer)

    respond_to do |format|
      if @result.success?
        format.turbo_stream { flash.now[:notice] = @result.messages }
      else
        format.turbo_stream { flash.now[:alert] = @result.messages }
      end
    end
  end

  private

  def set_grant
    @grant = @grant = Grant.kept.friendly.includes(:reviews, :reviewers).find(params[:grant_id])
  end

  def authorize_grant_editor
    authorize @grant, :edit?
  end

  def grant_reviewer_params
    params.require(:grant_reviewer).permit(:id, :reviewer_email)
  end
end
