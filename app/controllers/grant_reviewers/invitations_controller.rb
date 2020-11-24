module GrantReviewers
  class InvitationsController < ApplicationController
    before_action :set_grant

    def index
      authorize @grant, :edit?
      @invitations = GrantReviewer::Invitation.by_grant(@grant)
      skip_after_action :verify_policy_scoped
    end

    def update;end

    def create
      authorize @grant, :edit?
      invitation = GrantReviewer::Invitation.create(grant: @grant, inviter: current_user, email: params[:email])
      if invitation.errors.none?
        GrantReviewerInvitationMailer.invite(invitation: invitation, grant: @grant, inviter: current_user).deliver_now
        flash[:alert] = 'Invitation created.'
      else
        flash[:warning] = invitation.errors.full_messages
      end
      redirect_back fallback_location: grant_reviewers_path(@grant)
    end

    private

    def set_grant
      @grant = Grant.kept.friendly.find(params[:grant_id])
    end
  end
end
