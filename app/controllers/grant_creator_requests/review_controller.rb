module GrantCreatorRequests
  class ReviewController < ApplicationController
    before_action :set_and_authorize_grant_creator_request

    def show; end

    def update
      @grant_creator_request.reviewer = current_user
      if @grant_creator_request.update(grant_creator_request_review_params)
        send_requester_review_notification unless @grant_creator_request.status_pending?
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

    def send_requester_review_notification
      case @grant_creator_request.status
      when 'approved'
        GrantCreatorRequestReviewMailer.approved(request: @grant_creator_request).deliver_now
      when 'rejected'
        GrantCreatorRequestReviewMailer.rejected(request: @grant_creator_request).deliver_now
      end
    end
  end
end
