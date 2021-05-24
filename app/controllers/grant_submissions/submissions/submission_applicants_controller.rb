# frozen_string_literal: true
module GrantSubmissions
  module Submissions
    class SubmissionApplicantsController < ApplicationController
      # before_action     :set_submission

      skip_after_action :verify_policy_scoped, only: %i[index]

      def index
        @submission = GrantSubmission::Submission.find(params[:id])
        @submission_applicants = @submission.submission_applicants.includes(:applicant).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
      end

      # def create
      #   authorize @grant, :edit?

      #   email   = grant_reviewer_params[:reviewer_email].downcase.strip
      #   reviewer = User.find_by(email: email)

      #   if reviewer.nil?
      #     flash[:alert] = "Could not find a user with the email: #{email}. #{helpers.link_to 'Invite them to be a reviewer', invite_grant_reviewers_path(@grant, email: email), method: :post, data: { confirm: "An email will be sent to #{email}. You will be notified when they accept or opt out."} }"
      #   else
      #     grant_reviewer = GrantReviewer.create(grant: @grant, reviewer: reviewer)
      #     if grant_reviewer.errors.none?
      #       flash[:success] = "Added #{helpers.full_name(grant_reviewer.reviewer)} as reviewer."
      #     else
      #       flash[:alert]   = grant_reviewer.errors.full_messages
      #     end

      #   end

      #   redirect_to grant_reviewers_path(@grant)
      # end

      def destroy
      #   authorize @grant, :edit?

      #   grant_reviewer = GrantReviewer.find(params[:id])

      #   if grant_reviewer.nil?
      #     flash[:alert] = 'Reviewer could not be found.'
      #   else
      #     result = GrantReviewerServices::DeleteReviewer.call(grant_reviewer: grant_reviewer)
      #     if result.success?
      #       flash[:success] = result.messages
      #     else
      #       flash[:alert] = result.messages
      #     end
      #   end

      #   redirect_to grant_reviewers_path(@grant)
      end

      private

      # def set_submission

      #   @submission = GrantSubmission::Submission.find(params[:submission_id])
      # end

      def submission_applicant_params
        params.require(:submission_applicant).permit(:submission, :applicant)
      end
    end
  end
end