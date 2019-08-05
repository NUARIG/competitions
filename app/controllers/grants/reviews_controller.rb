module Grants
  class ReviewsController < ApplicationController
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      @grant = Grant.friendly.find(params[:grant_id])
      authorize @grant, :grant_viewer_access?
      @reviews = Review.by_grant(@grant)
    end
  end
end
