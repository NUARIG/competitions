module GrantReviewers
  module Invitations
    class RemindersController < InvitationsController
      def index
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
        redirect_back fallback_location: grant_invitations_path(@grant)
      end

      def show
        invitation = GrantReviewer::Invitation.find(params[:id])

        if invitation.present? && invitation.invitee.nil?
          send_reminder_email(invitation)
          flash[:success] = "A reminder has been sent to #{invitation.email}."
        else
          flash[:warning] = 'A reminder could not be sent to the selected email address.'
        end

        redirect_back fallback_location: grant_invitations_path(@grant)
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
