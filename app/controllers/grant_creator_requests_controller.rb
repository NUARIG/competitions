# frozen_string_literal: true

class GrantCreatorRequestsController < ApplicationController
  # before_action     :set_grant_creator_request, only: %i[edit show update]
  skip_after_action :verify_policy_scoped,      only: %i[index]

  def index
    authorize GrantCreatorRequest, :review?
    @grant_creator_requests = GrantCreatorRequest.pending.order('created_at DESC')
  end

  def new
    authorize GrantCreatorRequest, :create?
    if current_user.grant_creator?
      flash[:warning] = 'You already have permission to create grants.'
      redirect_to profile_path
    else
      @grant_creator_request = GrantCreatorRequest.new
      @grant_creator_request.requester = current_user
    end
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
    set_grant_creator_request
    authorize @grant_creator_request
  end

  def show
    set_grant_creator_request
    authorize @grant_creator_request
    render :edit
  end

  def update
    set_grant_creator_request
    authorize @grant_creator_request
    if @grant_creator_request.update_attributes(grant_creator_request_params)
      flash[:success] = 'Your request has been updated. You will be notified after review.'
      redirect_to profile_path
    else
      flash.now[:alert] = @grant_creator_request.errors.full_messages
      render :edit
    end
  end

  private

  def grant_creator_request_params
    params.require(:grant_creator_request).permit(:request_comment)
  end

  def set_grant_creator_request
    @grant_creator_request = GrantCreatorRequest.find(params[:id])
  end
end
