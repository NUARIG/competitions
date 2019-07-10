# frozen_string_literal: true

module Grants
  class GrantReviewersController < ApplicationController
    before_action     :set_grant

    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      authorize @grant, :grant_viewer_access?

      @grant_reviewers        = @grant.grant_reviewers
      # @grant_reviewers        = @grant.reviewers
      @unassigned_submissions = @grant.submissions #.unassigned_submissions(@grant.max_reviewers_per_proposal).includes(:applicant).order("#{User.table_name}.last_name, #{User.table_name}.first_name"))
    end

    def create
      authorize @grant, :grant_editor_access?

      email   = grant_reviewer_params[:reviewer_email].strip
      reviewer = User.find_by(email: email)

      if reviewer.nil?
        flash[:alert] = "Could not find user with email: #{email}. "
      else
        if grant_reviewer = GrantReviewer.create(grant: @grant, reviewer: reviewer)
          flash[:success] = "Added #{grant_reviewer.reviewer.first_name} as reviewer."
        else
          flash[:alert]   = 'Reviewer not created'
        end
        # prep_reviewer_data
      end

      redirect_to grant_reviewers_path(@grant)
    end

    def destroy
      authorize @grant, :grant_editor_access?

      grant_reviewer = GrantReviewer.find(params[:id])

      if grant_reviewer.nil?
        flash[:notice] = 'Could not find this reviewer to delete.'
      else
        # *#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
        # TODO: MOVE THIS TO A SERVICE OBJECT  #
        # *#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
        reviewer = grant_reviewer.reviewer
        # user_reviews = reviewer.submission_reviews.this_project(@project.id)
        flash[:success] = "Removed reviewer #{reviewer.first_name} #{reviewer.last_name}"
        # if user_reviews.length > 0
          flash[:warning] = "NOTE: DELETE REVIEWS HERE"
          # user_reviews.each do |sr|
          #   sr.destroy
        # end
        grant_reviewer.destroy
      end

      redirect_to grant_reviewers_path(@grant)
    end

    private

    def set_grant
      @grant = Grant.not_deleted.with_organization.friendly.find(params[:grant_id])
    end

    def grant_reviewer_params
      params.require(:grant_reviewer).permit(:id, :reviewer_email)
      # params.require(:grant_id).permit(:id,
      #                                  :reviewer_email)
    end
  end
end
