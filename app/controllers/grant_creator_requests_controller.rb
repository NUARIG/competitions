# frozen_string_literal: true

class GrantCreatorRequestsController < ApplicationController
  def new
    @grant_creator_request = GrantCreatorRequest.new
    authorize @grant_creator_request
    @grant_creator_request.requester = current_user
  end

  def create
    authorize GrantCreatorRequest, :create?
    @grant_creator_request = GrantCreatorRequest.new(grant_creator_request_params)
    @grant_creator_request.requester = current_user

    respond_to do |format|
      if @grant_creator_request.save
        # TODO: Notify admins?
        flash[:success] = 'Your request has been sent. You will be notified after review.'
        format.html { redirect_to profile_path }
      else
        flash[:alert] = @grant_creator_request.errors.full_messages
        format.html { render :new }
      end
    end
  end

  def edit
    @grant_creator_request = GrantCreatorRequest.find(params[:id])
    authorize @grant_creator_request
  end

  def show
    @grant_creator_request = GrantCreatorRequest.find(params[:id])
    authorize @grant_creator_request
  end

  def update
    authorize @grant_creator_request
  end

  def destroy
    authorize @grant_creator_request
  end

  private

  def grant_creator_request_params
    params.require(:grant_creator_request).permit(:request_comment)
  end

  def set_grant_creator_request
    @grant = GrantCreatorRequest.find(params[:id])
  end

end
