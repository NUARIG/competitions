module Profiles
  class ReviewsController < ApplicationController
    def index
      @q              = current_user.reviews.kept.with_grant_and_submitter_and_applicants.ransack(params[:q])
      @q.sorts        = 'created_at desc' if @q.sorts.empty?
      @pagy, @reviews = pagy_array(@q.result.to_a.uniq, i18n_key: 'activerecord.models.review')
      skip_policy_scope
    end
  end
end
