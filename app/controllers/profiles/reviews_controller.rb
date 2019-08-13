module Profiles
  class ReviewsController < ApplicationController

    def index
      @reviews = current_user.reviews.with_grant_and_applicant.by_created_at
      skip_policy_scope
    end
  end
end