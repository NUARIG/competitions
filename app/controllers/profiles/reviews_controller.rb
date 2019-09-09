module Profiles
  class ReviewsController < ApplicationController

    def index
      @pagy, @reviews = pagy(current_user.reviews.with_grant_and_applicant.order_by_created_at, i18n_key: 'activerecord.models.review')
      skip_policy_scope
    end
  end
end
