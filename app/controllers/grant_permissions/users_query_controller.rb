module GrantPermissions
  class UsersQueryController < GrantPermissionsController
    skip_before_action :set_paper_trail_whodunnit, :audit_action

    respond_to :json

    def index
      if params[:q].size >= 3
        grant = Grant.includes(:grant_permissions).find(params[:grant_id])
        users = User.where.not(id: grant.grant_permissions.map(&:user_id)).where("email ILIKE ?", "%#{params[:q]}%").distinct
        
        render json: users.map{ |u| { text: u.email, value: u.id } }
      else
        render json: [{}]
      end
    end
  end
end
