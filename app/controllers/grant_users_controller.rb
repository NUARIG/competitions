# frozen_string_literal: true

class GrantUsersController < ApplicationController
  include WithGrantRoles

  before_action :set_grant
  before_action :set_grant_user, only: %i[edit update destroy]

  # GET /grants/:study_id/grant_users
  def index
    authorize @grant, :edit?
    @grant_users       = @grant.grant_users.all
    @current_user_role = current_user_grant_permission
  end

  # GET /grants/:study_id/grant_user/new
  def new
    authorize @grant, :edit?
    @users      = unassigned_users_by_grant
    @grant_user = GrantUser.new(grant: @grant)
    # authorize @grant_user
  end

  def edit
    authorize @grant, :edit?
    @user = @grant_user.user
    @role = @grant_user.grant_role
  end

  # POST /questions
  # POST /questions.json
  def create
    authorize @grant, :edit?
    @grant_user = GrantUser.new(grant_user_params)
    respond_to do |format|
      if @grant_user.save
        flash[:success] = @grant_user.user.name + ' was granted \'' + @grant_user.grant_role + '\' permissions for this grant.'
        format.html { redirect_to edit_grant_path(@grant, anchor: 'permissions') }
        # format.html { redirect_to grant_grant_users_path(@grant) }
        format.json { render :show, status: :created, location: @grant_user }
      else
        @users = unassigned_users_by_grant
        flash[:alert] = @grant_user.errors.full_messages
        format.html { render :new }
        format.json { render json: @grant_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    authorize @grant, :edit?
    respond_to do |format|
      if @grant_user.update(grant_user_params)
        flash[:success] = @grant_user.user.name + '\'s permission was changed to \'' + @grant_user.grant_role + '\' for this grant.'
        #format.html { redirect_to grant_grant_users_path(@grant) }
        format.html { redirect_to edit_grant_path(@grant, anchor: 'permissions') }
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
    authorize @grant, :destroy?
    @grant_user.destroy
    respond_to do |format|
      flash[:success] = @grant_user.user.name + '\'s role was removed for this grant.'
      format.html { redirect_to edit_grant_path(@grant, anchor: 'permissions') }
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

  # def unassigned_users_by_organization_and_grant
  #   User.where(organization: @grant.organization)
  #       .left_outer_joins(:grant_users)
  #       .where.not(id: @grant.grant_users.map(&:user_id))
  # end

  def unassigned_users_by_grant
    User.left_outer_joins(:grant_users)
        .where.not(id: @grant.grant_users.map(&:user_id))
  end

  def grant_user_params
    params.require(:grant_user).permit(:grant_id, :user_id, :grant_role)
  end
end
