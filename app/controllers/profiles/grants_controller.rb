module Profiles
  class GrantsController < ApplicationController

    def index
      @grants = current_user.editable_grants.not_deleted.by_publish_date
      skip_policy_scope
    end
  end
end

