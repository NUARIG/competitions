# frozen_string_literal: true
module GrantSubmissions
  module Submissions
    class SubmissionApplicantsController < ApplicationController
      before_action     :set_submission_and_grant


      def index
        authorize @grant, :grant_editor_access?

        @grant_reviewers        = @grant.grant_reviewers.includes(:reviewer).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
        @unassigned_submissions = @grant.submissions.submitted.to_be_assigned(@grant.max_reviewers_per_submission).includes(:submitter).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
      end

      def new
        @applicant = GrantSubmission::SubmissionApplicant.new(submission: @submission)
        authorize @applicant
        render 'new'
      end

      def create
        # email   = submission_applicant_params[:applicant_email].downcase.strip
        # user = User.find_by(email: email)

        # if user.nil?
        #   flash[:alert] = "Could not find a user with the email: #{email}."
        #   # #{helpers.link_to 'Invite them to be a reviewer', invite_grant_reviewers_path(@grant, email: email), method: :post, data: { confirm: "An email will be sent to #{email}. You will be notified when they accept or opt out."} }"
        # else
        #   applicant = GrantSubmission::SubmissionApplicant.create(submission: @submission, applicant: user)
        #   if submission_applicant.errors.none?
        #     flash[:success] = "Added #{helpers.full_name(submission_applicant.applicant)} as applicant."
        #   else
        #     flash[:alert]   = submission_applicant.errors.full_messages
        #   end

        # end

        redirect_to new_grant_submission_path(@submission)
      end

      def destroy
        applicant = GrantSubmission::SubmissionApplicant.find(params[:id])
        authorize applicant
        # authorize @submission, :edit?

        if applicant.nil?
          flash[:alert] = 'Applicant could not be found.'
        else
          if applicant.destroy
            flash[:notice] = 'Applicant was deleted.'
            redirect_to edit_grant_submission_path(@grant, @submission)
          else
            flash[:error] = applicant.errors.to_a
            redirect_back fallback_location: edit_grant_submission_path(@grant, @submission)
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