module Profiles
  class GrantsController < ApplicationController

    def index
      @pagy, @grants = pagy(current_user.editable_grants.not_deleted.by_publish_date, i18n_key: 'activerecord.models.grant')
      skip_policy_scope
    end
  end
end

