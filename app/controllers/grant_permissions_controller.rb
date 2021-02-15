class GrantPermissionsController < ApplicationController
  before_action :set_grant, except: :index
  before_action :set_grant_permission, only: %i[edit update destroy]
  before_action :authorize_grant_editor, except: %[index]

  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    @grant = Grant.kept.includes(grant_permissions: :user).friendly.find(params[:grant_id])
    @pagy, @grant_permissions = pagy(@grant.grant_permissions, i18n_key: 'activerecord.models.grant_permission')
    authorize_grant_viewer
  end

  # GET /grants/:id/grant_permission/new
  def new
    @grant_permission = GrantPermission.new(grant: @grant)
  end

  def edit
    @user = @grant_permission.user
    @role = @grant_permission.role
  end

  # POST /grants/:id/grant_permission
  # POST /grants/:id/grant_permission.json
  def create
    @grant_permission = GrantPermission.new(grant_permission_params)
    respond_to do |format|
      if @grant_permission.save
        flash[:notice] = helpers.full_name(@grant_permission.user) + ' was granted \'' + @grant_permission.role + '\' permissions for this grant.'
        format.html { redirect_to grant_grant_permissions_path(@grant) }
        format.json { render :show, status: :created, location: @grant_permission }
      else
        flash[:alert] = @grant_permission.errors.full_messages
        format.html { render :new }
        format.json { render json: @grant_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grants/:id/grant_permission/1
  # PATCH/PUT /grants/:id/grant_permission/1.json
  def update
    respond_to do |format|
      if @grant_permission.update(grant_permission_params)
        # TODO: user may have changed their own permissions. authorize @grant, @grant_permission, :index?
        flash[:notice] = helpers.full_name(@grant_permission.user) + '\'s permission was changed to \'' + @grant_permission.role + '\' for this grant.'
        format.html { redirect_to grant_grant_permissions_path(@grant) }
        format.json { render :show, status: :ok, location: @grant_permission }
      else
        format.html { redirect_to edit_grant_grant_permission_path(@grant, @grant_permission), alert: @grant_permission.errors.full_messages }
        format.json { render json: @grant_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grant_permission/1
  # DELETE /grant_permission/1.json
  def destroy
    @grant_permission.destroy
    if @grant_permission.errors.any?
      flash[:alert] = @grant_permission.errors.full_messages
    else
      flash[:notice] = helpers.full_name(@grant_permission.user) + '\'s role was removed for this grant.'
    end
    respond_to do |format|
      format.html { redirect_to grant_grant_permissions_path(@grant) }
      format.json { head :no_content }
    end
  end

  private

  def set_grant
    @grant = Grant.kept.friendly.find(params[:grant_id])
  end

  def set_grant_permission
    @grant_permission = GrantPermission.find(params[:id])
  end

  def authorize_grant_viewer
    authorize @grant, :grant_viewer_access?
  end

  def authorize_grant_editor
    authorize @grant, :grant_editor_access?
  end

  def grant_permission_params
    params.require(:grant_permission).permit(
      :grant_id,
      :user_id,
      :role,
      :submission_notification
    )
  end
end
