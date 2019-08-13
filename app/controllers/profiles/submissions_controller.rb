module Profiles
  class SubmissionsController < ApplicationController

    def index
      @submissions = current_user.submissions.order('created_at DESC')
      skip_policy_scope
    end
  end
end