class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :audit_action, if: -> { params[:q].present? }

  def index
    @grants = Grant.kept.public_grants.includes(:grant_permissions)

    skip_policy_scope
  end
end
