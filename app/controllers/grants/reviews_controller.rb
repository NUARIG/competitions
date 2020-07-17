module Grants
  class ReviewsController < ApplicationController
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index

      if request.format.html?
        @grant = Grant.kept.friendly.with_reviews.find(params[:grant_id])
        authorize @grant, :grant_viewer_access?

        @q              = Review.by_grant(@grant).ransack(params[:q])
        @q.sorts        = 'applicant_last_name asc' if @q.sorts.empty?
        @pagy, @reviews = pagy(@q.result, i18n_key: 'activerecord.models.review')
      elsif request.format.xlsx?
        @grant          = Grant.with_criteria. kept.friendly.find(params[:grant_id])
        authorize       @grant, :grant_viewer_access?

        @criteria       = @grant.criteria
        @reviews        = Review.with_grant_and_applicant.with_criteria_reviews.by_grant(@grant)
      end

      respond_to do |format|
        format.html
        format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=reviews-#{@grant.name.gsub(/\W/,'')}-#{DateTime.now.strftime('%Y_%m%d')}.xlsx"}
      end
    end
  end
end
