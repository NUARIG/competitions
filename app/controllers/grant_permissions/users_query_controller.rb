module GrantPermissions
  class UsersQueryController < GrantPermissionsController
    respond_to :json

    def index
      @grant = Grant.find(params[:grant_id])
      @users = User.left_outer_joins(:grant_permissions)
        .where.not(id: @grant.grant_permissions.map(&:user_id))
        .where("email LIKE ?", "%#{params[:q]}%")
        .distinct
      respond_with @users.to_json
    end
  end
end