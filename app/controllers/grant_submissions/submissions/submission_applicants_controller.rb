# frozen_string_literal: true
module GrantSubmissions
  module Submissions
    class SubmissionApplicantsController < GrantBaseController
      before_action     :set_submission_and_grant


      def index
        skip_policy_scope
        authorize @submission, :edit?
        @submission_applicants = @submission.submission_applicants.includes(:applicant).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
      end

      def create
        authorize @submission, :edit?

        email   = submission_applicant_params[:applicant_email].downcase.strip
        user = User.find_by(email: email)

        if user.nil?
          flash[:alert] = "Could not find a user with the email: #{email}."
          # #{helpers.link_to 'Invite them to be a reviewer', invite_grant_reviewers_path(@grant, email: email), method: :post, data: { confirm: "An email will be sent to #{email}. You will be notified when they accept or opt out."} }"
        else
          submission_applicant = GrantSubmission::SubmissionApplicant.create(submission: @submission, applicant: user)
          if submission_applicant.errors.none?
            flash[:success] = "Added #{helpers.full_name(submission_applicant.applicant)} as applicant."
          else
            flash[:alert]   = submission_applicant.errors.full_messages
          end

        end

        redirect_to grant_submission_submission_applicants_path(@grant, @submission)
      end

      def destroy
        authorize @submission, :edit?
        applicant = GrantSubmission::SubmissionApplicant.find(params[:id])

        if applicant.nil?
          flash[:alert] = 'Applicant could not be found.'
        else
          if applicant.destroy
            flash[:notice] = 'Applicant was deleted.'
            redirect_to grant_submission_submission_applicants_path(@grant, @submission)
          else
            flash[:error] = applicant.errors.to_a
            redirect_to grant_submission_submission_applicants_path(@grant, @submission)
          end
        end
      end

      private

      def set_submission_and_grant
        @submission = GrantSubmission::Submission.find(params[:submission_id])
        @grant = @submission.grant
      end

      def submission_applicant_params
        params.require(:grant_submission_submission_applicant).permit(:id, :applicant_email)
      end
    end
  end
end