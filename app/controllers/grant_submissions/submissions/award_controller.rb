module GrantSubmissions
  module Submissions
    class AwardController < SubmissionsController
      def edit;
      end

      def update
        set_submission
        authorize @submission, :award?

        if @submission.update(submission_params)
          respond_to do |format|
            format.turbo_stream
          end
        else
          render :edit
        end
      end

      private

      def submission_params
        params.require(:grant_submission_submission).permit(:id, :grant_id,:awarded)
      end
    end
  end
end
