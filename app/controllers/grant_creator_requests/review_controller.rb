module GrantCreatorRequests
  class ReviewController < GrantCreatorRequestsController
    before_action :set_and_authorize_grant_creator_request

    def show
    end

    def update
      @grant_creator_request.reviewer = current_user
      if @grant_creator_request.update(grant_creator_request_review_params)
        flash[:success] = 'Request was successfully reviewed.'
        redirect_to grant_creator_requests_path
      else
        flash.now[:alert] = @grant_creator_request.errors.full_messages
        render :show
      end
    end

    private

    def grant_creator_request_review_params
      params.require(:grant_creator_request).permit(:status, :review_comment)
    end

    def set_and_authorize_grant_creator_request
      @grant_creator_request = GrantCreatorRequest.find(params[:grant_creator_request_id])
      authorize @grant_creator_request, :review?
    end
  end
end
