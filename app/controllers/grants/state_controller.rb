# frozen_string_literal: true

module Grants
  class StateController < ApplicationController
    before_action :set_grant, only: :update

    # PATCH/PUT /grants/1/state
    def update
      authorize @grant, :update?
      if @grant.update(grant_params)
        flash[:notice] = "Publish status was changed to #{@grant.state}."
        redirect_back fallback_location: grant_path(@grant)
      else
        @grant.errors.add(:base, "Status change failed. This grant is still in #{@grant.reload.state} mode.")
        flash[:alert] = @grant.errors.full_messages
        redirect_back fallback_location: grant_path(@grant)
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
