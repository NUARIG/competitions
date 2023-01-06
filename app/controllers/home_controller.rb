class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :audit_action, if: -> { params[:q].present? }

  def index
    @q      = Grant.kept.public_grants.includes(:grant_permissions).ransack(params[:q])
    @grants = @q.result(distinct: true)

    skip_policy_scope
  end
end
