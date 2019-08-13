module Profiles
  class SubmissionsController < ApplicationController

    def index
      @submissions = current_user.submissions.by_created_at
      skip_policy_scope
    end
  end
end