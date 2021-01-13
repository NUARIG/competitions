module GrantPermissions
  class UsersQueryController < GrantPermissionsController
    respond_to :json

    def index
      @grant = Grant.find(params[:grant_id])
      @users = User.where.not(id: @grant.grant_permissions.map(&:user_id))
        .where("email LIKE ?", "%#{params[:q]}%")
        .distinct
      respond_with @users.to_json
    end
  end
end
