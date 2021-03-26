module GrantReviewers
  class InvitationsController < ApplicationController
    before_action :set_grant
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      authorize @grant, :edit?
      @invitations = GrantReviewer::Invitation.with_inviter.by_grant(@grant)
    end

    def update;end

    def create
      authorize @grant, :edit?
      invitation = GrantReviewer::Invitation.new(grant: @grant, inviter: current_user, email: params[:email])
      if invitation.save
        GrantReviewerInvitationMailer.invite(invitation: invitation, grant: @grant, inviter: current_user).deliver_now
        flash[:alert] = "Invitation to #{invitation.email} has been sent. #{helpers.link_to 'View all invitations', grant_invitations_path(@grant)}"
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
