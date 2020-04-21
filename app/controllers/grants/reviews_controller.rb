module Grants
  class ReviewsController < ApplicationController
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      @grant = Grant.kept.friendly.find(params[:grant_id])
      authorize @grant, :grant_viewer_access?

      if request.format.html?
        @q              = Review.by_grant(@grant).ransack(params[:q])
        @q.sorts        = 'applicant_last_name asc' if @q.sorts.empty?
        @pagy, @reviews = pagy(@q.result, i18n_key: 'activerecord.models.review')
      elsif request.format.xlsx?
        @reviews        = Review.with_grant_and_applicant.with_criteria_reviews.by_grant(@grant)
      end

      respond_to do |format|
        format.html
        format.xlsx
      end
    end
  end
end
