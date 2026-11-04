# frozen_string_literal: true

module Users
  class GrantPermissionsController < ApplicationController
    before_action :set_user
    skip_after_action :verify_policy_scoped, only: :index

    def index
      authorize @user, :edit?

      @pagy, @grant_permissions = pagy(
        @user.grant_permissions
             .includes(:grant)
             .joins(:grant)
             .merge(Grant.kept)
             .order('grants.publish_date desc, grants.name asc'),
        items: 5,
        i18n_key: 'activerecord.models.grant_permission',
        link_extra: 'data-turbo-frame="user_grant_permissions"'
      )
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end
