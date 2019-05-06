# frozen_string_literal: true

module Grants
  class StateController < ApplicationController
    before_action :set_grant, only: :update

    # PATCH/PUT /grants/1/state
    def update
      authorize @grant
      respond_to do |format|
        if @grant.update(grant_params)
          format.html { redirect_back fallback_location: grant_path(@grant),
                        notice: "Publish status was changed to #{@grant.state}." }
        else
          format.html { redirect_back fallback_location: grant_path(@grant),
                        alert: "Status change failed. This grant is still in #{@grant.state} mode." }
        end
      end
    end

    private

    def grant_params
      params.require(:grant_state).permit(:state)
    end

    def set_grant
      @grant = Grant.not_deleted.friendly.find(params[:grant_id])
    end
  end
end
