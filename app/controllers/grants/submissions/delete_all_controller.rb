module Grants
  module Submissions
    class DeleteAllController < Grants::SubmissionsController
      before_action :set_grant

      def index
        # TODO: Add more guards
        authorize @grant, :edit?
        if @grant.submissions.delete_all
          flash[:success] = 'All Submissions to this grant have been deleted.'
          redirect_back fallback_location: grant_submissions_path(@grant)
        else
          flash[:alert] = 'Submissions could not be deleted at this time.'
          redirect_back fallback_location: grant_submissions_path(@grant)
        end
      end
    end
  end
end
