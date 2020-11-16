module Profiles
  class GrantsController < ApplicationController
    def index
      @q = current_user.editable_grants.kept.ransack(params[:q])
      @q.sorts = 'publish_date desc' if @q.sorts.empty?
      @pagy, @grants = pagy(@q.result, i18n_key: 'activerecord.models.grant')
      skip_policy_scope
    end
  end
end

