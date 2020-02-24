module Grants
  class ReviewsController < ApplicationController
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      @grant = Grant.kept.friendly.find(params[:grant_id])
      authorize @grant, :grant_viewer_access?

      @q              = Review.by_grant(@grant).ransack(params[:q])
      @q.sorts        = 'applicant_last_name asc' if @q.sorts.empty?
      @pagy, @reviews = pagy(@q.result, i18n_key: 'activerecord.models.review')
    end
  end
end
