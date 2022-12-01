class GrantPermissionsController < ApplicationController
  before_action :set_grant, except: :index
  before_action :set_grant_permission, only: %i[edit update destroy]
  before_action :authorize_grant_editor, except: %[index]

  skip_after_action :verify_policy_scoped, only: %i[index]

  def index
    flash.keep
    @grant = Grant.kept.friendly.find(params[:grant_id])
    authorize_grant_viewer

    @grant_permissions  = GrantPermission.joins(:user).where(grant: @grant).merge(User.order(last_name: :asc))
    set_pagination
  end

  def new
    @grant_permission = GrantPermission.new(grant: @grant)
  end

  def edit
    @user = @grant_permission.user
    @role = @grant_permission.role
  end

  def create
    @grant_permission = GrantPermission.new(grant_permission_params)
    respond_to do |format|
      if @grant_permission.save
        flash[:notice] = helpers.full_name(@grant_permission.user) + ' was granted \'' + @grant_permission.role.capitalize + '\' permissions for this grant.'
        format.html { redirect_to grant_grant_permissions_path(@grant) }
      else
        flash[:alert] = @grant_permission.errors.full_messages
        format.html { render :new }
      end
    end
  end

  def update
    if @grant_permission.update(grant_permission_params)
      notice = "#{user_flash_display} role on this grant was successfully updated."
      respond_to do |format|
        format.html         { redirect_to grant_grant_permissions_path(@grant), notice: notice }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    else
      alert = @grant_permission.errors.full_messages

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @grant_permission.destroy
    if @grant_permission.errors.any?
      flash[:alert] = @grant_permission.errors.full_messages
      render :edit, status: :unprocessable_entity
    else
      # Need to set pagination in order to update the header permission count
      set_pagination
      notice = "#{user_flash_display} role on this grant was removed."

      respond_to do |format|
        # format.html          { redirect_to grant_grant_permissions_path(@grant), notice: notice }
        format.turbo_stream  { flash.now[:notice] = notice }
      end
    end
  end

  private

  def set_grant
    @grant = Grant.includes(:grant_permissions).kept.friendly.find(params[:grant_id])
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
      :submission_notification,
      :contact
    )
  end

  def set_pagination
    @pagy, @grant_permissions = pagy((@grant_permissions || @grant.grant_permissions), i18n_key: 'activerecord.models.grant_permission')
  end

  def user_flash_display
    @grant_permission.user == current_user ? 'Your' : "#{helpers.full_name(@grant_permission.user)}'s"
  end
end
