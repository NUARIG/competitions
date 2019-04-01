module Grants
  class GrantUsersController < ApplicationController
    include WithGrantRoles

    before_action :set_grant, except: :index
    before_action :set_grant_and_grant_users, only: :index
    before_action :set_grant_user, only: %i[edit update destroy]
    before_action :authorize_grant

    def index
      @current_user_role = current_user_grant_permission
    end

    # GET /grants/:id/grant_user/new
    def new
      @users      = unassigned_users_by_grant
      @grant_user = GrantUser.new(grant: @grant)
    end

    def edit
      @user = @grant_user.user
      @role = @grant_user.grant_role
    end

    # POST /grants/:id/grant_user
    # POST /grants/:id/grant_user.json
    def create
      @grant_user = GrantUser.new(grant_user_params)
      respond_to do |format|
        if @grant_user.save
          flash[:notice] = @grant_user.user.name + ' was granted \'' + @grant_user.grant_role + '\' permissions for this grant.'
          format.html { redirect_to grant_grant_users_path(@grant) }
          format.json { render :show, status: :created, location: @grant_user }
        else
          @users        = unassigned_users_by_grant
          flash[:alert] = @grant_user.errors.full_messages
          format.html { render :new }
          format.json { render json: @grant_user.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /grants/:id/grant_user/1
    # PATCH/PUT /grants/:id/grant_user/1.json
    def update
      authorize @grant, :edit?
      respond_to do |format|
        if @grant_user.update(grant_user_params)
          # TODO: user may have changed their own permissions. authorize @grant, @grant_user, :index?
          flash[:notice] = @grant_user.user.name + '\'s permission was changed to \'' + @grant_user.grant_role + '\' for this grant.'
          format.html { redirect_to grant_grant_users_path(@grant) }
          format.json { render :show, status: :ok, location: @grant_user }
        else
          format.html { redirect_to edit_grant_grant_user_path(@grant, @grant_user), alert: @grant_user.errors.full_messages }
          format.json { render json: @grant_user.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /grant_user/1
    # DELETE /grant_user/1.json
    def destroy
      authorize @grant, :destroy?
      @grant_user.destroy
      if @grant_user.errors.any?
        flash[:alert] = @grant_user.errors.full_messages
      else
        flash[:notice] = @grant_user.user.name + '\'s role was removed for this grant.'
      end
      respond_to do |format|
        format.html { redirect_to grant_grant_users_path(@grant) }
        format.json { head :no_content }
      end
    end


    private

    def set_grant
      @grant = Grant.find(params[:grant_id])
    end

    def set_grant_and_grant_users
      @grant       = Grant.includes(:grant_users).find(params[:grant_id])
      @grant_users = @grant.grant_users
    end

    def set_grant_user
      @grant_user = GrantUser.find(params[:id])
    end

    def authorize_grant
      authorize @grant, :grant_viewer_access?
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
end
