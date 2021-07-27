# frozen_string_literal: true
module GrantSubmissions
  module Submissions
    class SubmissionApplicantsController < GrantBaseController
      skip_after_action :verify_policy_scoped, only: %i[index]
      before_action     :set_submission_and_grant

      def index
        authorize @submission, :edit?
        @submission_applicants = @submission.submission_applicants.includes(:applicant).order("#{User.table_name}.last_name, #{User.table_name}.first_name")
      end

      def create
        authorize @submission, :edit?

        email   = submission_applicant_params[:applicant_email].downcase.strip
        user = User.find_by(email: email)

        if user.nil?
          flash[:alert] = "Could not find a user with the email: #{email}."
        else
          submission_applicant = GrantSubmission::SubmissionApplicant.create(submission: @submission, applicant: user)
          if submission_applicant.errors.none?
            flash[:success] = "#{helpers.full_name(submission_applicant.applicant)} was added as applicant on #{@submission.title}."
          else
            flash[:alert]   = submission_applicant.errors.full_messages
          end

        end

        redirect_to grant_submission_submission_applicants_path(@grant, @submission)
      end

      def destroy
        authorize @submission, :edit?
        submission_applicant = GrantSubmission::SubmissionApplicant.find(params[:id])
        applicant = submission_applicant.applicant

        if submission_applicant.nil?
          flash[:alert] = 'Applicant could not be found.'
        else
          if submission_applicant.destroy
            flash[:notice] = "#{helpers.full_name(applicant)} is no longer an applicant on #{@submission.title}."
            redirect_to grant_submission_submission_applicants_path(@grant, @submission)
          else
            flash[:error] = submission_applicant.errors.to_a
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