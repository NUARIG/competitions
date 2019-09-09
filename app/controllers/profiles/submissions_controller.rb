module Profiles
  class SubmissionsController < ApplicationController

    def index
      @pagy, @submissions = pagy(current_user.submissions.order_by_created_at, i18n_key: 'activerecord.models.submission')
      skip_policy_scope
    end
  end
end
