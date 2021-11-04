module GrantReviewers
  module Invitations
    class RemindersController < InvitationsController
      def index
        authorize @grant, :edit?
        @open_invitations = GrantReviewer::Invitation
                              .with_inviter
                              .where(grant_id: @grant.id)
                              .open
        if @open_invitations.any?
          send_reminder_emails
          flash[:notice] = 'Reminder emails have been sent to those who have not yet responded.'
        else
          flash[:warning] = 'There are no open reviewer invitations for this grant. No reminders have been sent'
        end
        redirect_to grant_invitations_path(@grant)
      end

      private

      def send_reminder_emails
        @open_invitations.each do |invitation|
          GrantReviewerInvitationMailer.reminder(invitation: invitation, grant: @grant).deliver_now
          invitation.update(reminded_at: Time.now)
        end
      end
    end
  end
end
