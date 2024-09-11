# frozen_string_literal: true

module Grants
  class StateController < ApplicationController
    before_action :set_and_authorize_grant

    def publish
      if @grant.update(state: 'published')
        flash[:notice] = "Publish status was changed to #{@grant.state}."
        redirect_to grant_path(@grant)
      else
        @grant.errors.add(:base, :state_change_failed, state: @grant.reload.state)
        flash[:alert] = @grant.errors.full_messages
        redirect_to edit_grant_path(@grant)
      end
    end

    def draft
      if @grant.update(state: 'draft')
        flash[:notice] = "Publish status was changed to #{@grant.state}."
        redirect_to edit_grant_path(@grant)
      else
        @grant.errors.add(:base, :state_change_failed, state: @grant.reload.state)
        flash[:alert] = @grant.errors.full_messages
        redirect_to edit_grant_path(@grant)
      end
    end

    private

    def set_and_authorize_grant
      @grant = Grant.kept.friendly.find(params[:grant_id])
      authorize @grant, :update?
    end
  end
end
