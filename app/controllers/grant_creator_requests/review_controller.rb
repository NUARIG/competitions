module GrantCreatorRequests
  class ReviewController < GrantCreatorRequestsController
    before_action :set_and_authorize_grant_creator_request

    def show
    end

    def update
      if @grant_creator_request.update(grant_creator_request_review_params)
        flash[:success] = 'Request was successfully reviewed.'
        if @grant_creator_request.status_approved?
          @grant_creator_request.requester.update_attribute(:grant_creator, true)
        elsif
          @grant_creator_request.status_rejected?
          @grant_creator_request.requester.update_attribute(:grant_creator, false)
        end
      else
        flash.now[:alert] = @grant_creator_request.errors.full_messages
        render :show
      end
    end

    private

    def grant_creator_request_review_params
      params.require(:grant_creator_request_id).permit(grant_creator_request: [:status, :review_comment])
    end

    def set_and_authorize_grant_creator_request
      @grant_creator_request = GrantCreatorRequest.find(params[:grant_creator_request_id])
      authorize @grant_creator_request, :review?
    end
  end
end
