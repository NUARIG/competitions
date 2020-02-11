module Profiles
  class ReviewsController < ApplicationController
    def index
      @q              = current_user.reviews.with_grant_and_applicant.ransack(params[:q])
      @q.sorts        = 'created_at desc' if @q.sorts.empty?
      @pagy, @reviews = pagy(@q.result, i18n_key: 'activerecord.models.review')
      skip_policy_scope
    end
  end
end
