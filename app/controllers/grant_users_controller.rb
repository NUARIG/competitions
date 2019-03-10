# frozen_string_literal: true

class GrantUsersController < ApplicationController
  before_action :set_grant
  before_action :set_grant_user, only: %i[edit update destroy]

  # GET /grants/:study_id/grant_users
  def index
    @grant_users = @grant.grant_users.all
    if @grant_users.present?
      authorize @grant_users
    else
      authorize @grant
    end
  end

  # GET /grants/:study_id/grant_user/new
  def new
    @users      = unassigned_users_by_organization_and_grant
    @grant_user = GrantUser.new(grant: @grant)
    authorize @grant_user
  end

  def edit
    @user = @grant_user.user
    @role = @grant_user.grant_role
    authorize @grant_user
  end

  # POST /questions
  # POST /questions.json
  def create
    @grant_user = GrantUser.new(grant_user_params)
    authorize @grant_user
    respond_to do |format|
      if @grant_user.save
        flash[:success] = <<~SUCCESS
          #{@grant_user.user.name} was granted
          '#{@grant_user.grant_role}' permissions for this grant.
        SUCCESS
        format.html { redirect_to grant_grant_users_path(@grant) }
        format.json { render :show, status: :created, location: @grant_user }
      else
        @users = unassigned_users_by_organization_and_grant
        flash[:alert] = @grant_user.errors.full_messages
        format.html { render :new }
        format.json { render json: @grant_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    authorize @grant_user
    respond_to do |format|
      if @grant_user.update(grant_user_params)
        flash[:success] = <<~SUCCESS
          #{@grant_user.user.name}'s permission was changed to
          '#{@grant_user.grant_role}' for this grant.
        SUCCESS
        format.html { redirect_to grant_grant_users_path(@grant) }
        format.json { render :show, status: :ok, location: @grant_user }
      else
        @users = unassigned_users_by_organization_and_grant
        format.html { render :edit, alert: @grant_user.errors.full_messages }
        format.json { render json: @grant_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    authorize @grant_user
    @grant_user.destroy
    respond_to do |format|
      flash[:success] = <<~SUCCESS
        #{@grant_user.user.name}'s role was removed for this grant.
      SUCCESS
      format.html { redirect_to grant_grant_users_path }
      format.json { head :no_content }
    end
  end

  private

  def set_grant
    @grant = Grant.find(params[:grant_id])
  end

  def set_grant_user
    @grant_user = GrantUser.find(params[:id])
  end

  def unassigned_users_by_organization_and_grant
    User.where(organization: @grant.organization)
        .left_outer_joins(:grant_users)
        .where.not(id: @grant.grant_users.map(&:user_id))
  end

  def grant_user_params
    params.require(:grant_user).permit(:grant_id, :user_id, :grant_role)
  end
end
