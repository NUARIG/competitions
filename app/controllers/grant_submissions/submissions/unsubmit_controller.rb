module GrantSubmissions
  module Submissions
    class UnsubmitController < SubmissionsController
      def update
        set_submission
        authorize @submission, :unsubmit?

        if @submission.draft?
          flash[:warning] = 'This submission is already editable.'
        elsif @submission.update(state: GrantSubmission::Submission::SUBMISSION_STATES[:draft])
          flash[:success] = 'You have changed the status of this submission to Draft. It may now be edited.'
        else
          flash[:alert]   = @submission.errors.full_messages
        end

        respond_to do |format|
          format.html { redirect_back fallback_location: grant_submissions_path(@grant) }
        end
      end
    end
  end
end
