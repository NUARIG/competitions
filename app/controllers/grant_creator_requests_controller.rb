# frozen_string_literal: true

class GrantCreatorRequestsController < ApplicationController
  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    authorize GrantCreatorRequest, :review?
    @grant_creator_requests = GrantCreatorRequest.pending.order('created_at DESC')
  end

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
    render :edit
  end

  def update
    @grant_creator_request = GrantCreatorRequest.find(params[:id])
    authorize @grant_creator_request
    if @grant_creator_request.update_attributes(grant_creator_request_params)
      flash[:success] = 'Your request has been updated. You will be notified after review.'
      redirect_to profile_path
    else
      flash.now[:alert] = @grant_creator_request.errors.full_messages
      render :edit
    end
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
