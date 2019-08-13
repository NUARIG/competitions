module Profiles
  class ReviewsController < ApplicationController

    def index
      @reviews = current_user.reviews.order('created_at DESC')
      skip_policy_scope
    end
  end
end