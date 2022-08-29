module GrantReviewers
  module Invitations
    class RemindersController < InvitationsController
      def index
        @open_invitations = GrantReviewer::Invitation
                              .with_inviter
                              .where(grant_id: @grant.id)
                              .open
        respond_to do |format|
          if @open_invitations.any?
            send_reminder_emails
            format.html { redirect_to grant_invitations_url(@grant), notice: 'Reminder emails have been sent to those who have not yet responded.' }
          else
            format.html { redirect_to grant_invitations_url(@grant), alert: 'There are no open reviewer invitations for this grant. No reminders have been sent' }
          end
        end
      end

      def show
        invitation = GrantReviewer::Invitation.find(params[:id])

        respond_to do |format|
          if invitation.present? && invitation.invitee.nil?
            send_reminder_email(invitation)
            format.html { redirect_to grant_invitations_url(@grant), notice: "A reminder has been sent to #{invitation.email}." }
          else
            format.html { redirect_to grant_invitations_url(@grant), alert: 'A reminder could not be sent to the selected email address.' }
          end
        end
      end

      private

      def send_reminder_emails
        @open_invitations.each do |invitation|
          send_reminder_email(invitation)
        end
      end

      def send_reminder_email(invitation)
        GrantReviewerInvitationMailer.reminder(invitation: invitation, grant: @grant).deliver_now
        invitation.update(reminded_at: Time.now)
      end
    end
  end
end
