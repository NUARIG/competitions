module GrantReviewers
  class InvitationsController < ApplicationController
    before_action :set_grant
    before_action :authorize_user
    skip_after_action :verify_policy_scoped, only: %i[index]

    def index
      @invitations          = GrantReviewer::Invitation.with_inviter.by_grant(@grant)
      @has_open_invitations = @invitations.any?{ |invite| invite.confirmed_at.nil? && invite.opted_out_at.nil? }
    end

    def update;end

    def create
      invitation = GrantReviewer::Invitation.new(grant: @grant, inviter: current_user, email: params[:email])

      respond_to do |format|
        if invitation.save
          GrantReviewerInvitationMailer.invite(invitation: invitation, grant: @grant, inviter: current_user).deliver_now
          format.html { redirect_to grant_reviewers_url(@grant), notice: "Invitation to #{invitation.email} has been sent. #{helpers.link_to 'View all invitations', grant_invitations_path(@grant)}" }
        else
          format.html { redirect_to grant_reviewers_url(@grant), warning: invitation.errors.full_messages }
        end
      end
    end

    def destroy
      invitation = GrantReviewer::Invitation.find(params[:id])

      respond_to do |format|
        if invitation.invitee.nil? && invitation.destroy
          format.html { redirect_to grant_reviewers_url(@grant), notice: "The invitation to #{invitation.email} has been deleted." }
        else
          format.html { redirect_to grant_reviewers_url(@grant), warning: "Could not delete the invitation to #{invitation.email}." }
        end
      end
    end

    private

    def set_grant
      @grant = Grant.kept.friendly.find(params[:grant_id])
    end

    def authorize_user
      authorize @grant, :edit?
    end
  end
end
