module GrantReviewers
  class InvitationsController < ApplicationController
    before_action :set_grant

    def index
      authorize @grant, :edit?
      @invitations = GrantReviewer::Invitation.by_grant(@grant)
      skip_after_action :verify_policy_scope
    end

    def update;end

    def create
      authorize @grant, :edit?
      # if existing invite
      #   flash[:warning] = 'Email already invited.'
      # else
      #   create/send the invite
      flash[:alert] = 'Invitation sent.'
      redirect_back fallback_location: grant_reviewers_path(@grant)
    end

    private

    def set_grant
      @grant = Grant.kept
                    .friendly
                    .find(params[:grant_id])
    end
  end
end
