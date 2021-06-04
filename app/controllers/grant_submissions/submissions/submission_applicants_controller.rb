# frozen_string_literal: true
module GrantSubmissions
  module Submissions
    class SubmissionApplicantsController < ApplicationController
      before_action     :set_submission_and_grant

      # skip_after_action :verify_policy_scoped, only: %i[index]

      # def index
      #   @submission_applicants = @submission.submission_applicants.includes(:applicant).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
      # end

      def create
        authorize @submission, :edit?

        # email   = submission_applicant_params[:reviewer_email].downcase.strip
        # applicant = User.find_by(email: email)

        # if submission_applicant.nil?
        #   flash[:alert] = "Could not find a user with the email: #{email}."
        #   # #{helpers.link_to 'Invite them to be a reviewer', invite_grant_reviewers_path(@grant, email: email), method: :post, data: { confirm: "An email will be sent to #{email}. You will be notified when they accept or opt out."} }"
        # else
        #   submission_applicant = GrantSubmission::SubmissionApplicant.create(submission: @submission, applicant: applicant)
        #   if submission_applicant.errors.none?
        #     flash[:success] = "Added #{helpers.full_name(submission_applicant.applicant)} as applicant."
        #   else
        #     flash[:alert]   = submission_applicant.errors.full_messages
        #   end

        # end

        # redirect_to grant_submission_submission_path(@submission)
      end

      def destroy
        authorize @submission, :destroy
        applicant = GrantSubmission::SubmissionApplicant.find(params[:id])

        if applicant.nil?
          flash[:alert] = 'Applicant could not be found.'
        else
          if applicant.destroy
            flash[:notice] = 'Applicant was deleted.'
            redirect_to grant_submission_submission_applicants_path(@grant, @submission)
          else
            flash[:error] = applicant.errors.to_a
            redirect_back fallback_location: grant_submission_submission_appliacants_path(@grant, @submission)
          end
        end
      end

      private

      def set_submission_and_grant
        @submission = GrantSubmission::Submission.find(params[:submission_id])
        @grant = @submission.grant
      end

      def submission_applicant_params
        params.require(:submission_applicant).permit(:submission, :applicant)
      end
    end
  end
end