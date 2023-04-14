module GrantSubmissions
  module Submissions
    class AwardController < SubmissionsController
      def update
        set_submission
        authorize @submission, :grant_editor_access?

        if @submission.update(submission_params)
          flash[:notice] = "'#{@submission.title}' has been #{@submission.awarded ? 'awarded' : 'unawarded' }."
          respond_to do |format|
            format.html { redirect_to grant_submissions_path(@grant) }
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace(:flash, partial: 'layouts/flash')
            end
          end
        else
          flash.now[:alert] = "Award status could not be updated. #{@submission.errors[:base].join(', ')}"
          @submission.reload

          respond_to do |format|
            format.html { redirect_back fallback_location: grant_submissions_path(@grant) }
            format.turbo_stream do
              render :update, status: :unprocessable_entity
            end
          end
        end
      end

      private

      def submission_params
        params.require(:grant_submission_submission).permit(:id, :awarded)
      end
    end
  end
end
