module Grants
  class GrantPermissionsController < GrantBaseController
    include WithGrantRoles

    before_action :set_grant, except: :index
    before_action :set_grant_and_grant_permissions, only: :index
    before_action :set_grant_permission, only: %i[edit update destroy]
    before_action :authorize_grant_editor_access, except: %i[index destroy]

    def index
      @grant_permissions = GrantPermission.where(grant: @grant)
      @grant_permissions = policy_scope(GrantPermission,
                                        policy_scope_class: Grant::GrantPermissionPolicy::Scope)

      @current_user_role = current_user_grant_permission
    end

    # GET /grants/:id/grant_permission/new
    def new
      @users            = unassigned_users_by_grant
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
          flash[:notice] = @grant_permission.user.name + ' was granted \'' + @grant_permission.role + '\' permissions for this grant.'
          format.html { redirect_to grant_grant_permissions_path(@grant) }
          format.json { render :show, status: :created, location: @grant_permission }
        else
          @users        = unassigned_users_by_grant
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
          flash[:notice] = @grant_permission.user.name + '\'s permission was changed to \'' + @grant_permission.role + '\' for this grant.'
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
      authorize @grant, :destroy?
      @grant_permission.destroy
      if @grant_permission.errors.any?
        flash[:alert] = @grant_permission.errors.full_messages
      else
        flash[:notice] = @grant_permission.user.name + '\'s role was removed for this grant.'
      end
      respond_to do |format|
        format.html { redirect_to grant_grant_permissions_path(@grant) }
        format.json { head :no_content }
      end
    end


    private

    def set_grant
      @grant = Grant.friendly.find(params[:grant_id])
    end

    def set_grant_and_grant_permissions
      @grant       = Grant.includes(:grant_permissions).friendly.find(params[:grant_id])
      @grant_permissions = @grant.grant_permissions
    end

    def set_grant_permission
      @grant_permission = GrantPermission.find(params[:id])
    end

    def authorize_grant_editor_access
      authorize @grant, :grant_editor_access?
    end

    def unassigned_users_by_grant
      User.left_outer_joins(:grant_permissions)
          .where.not(id: @grant.grant_permissions.map(&:user_id))
    end

    def grant_permission_params
      params.require(:grant_permission).permit(
        :grant_id,
        :user_id,
        :role
      )
    end

  end
end
