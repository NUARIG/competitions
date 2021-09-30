class GrantReviewerInvitationMailer < ApplicationMailer
  def invite(invitation:, grant:, inviter:)
    @email      = invitation.email
    @grant      = grant
    @inviter    = inviter

    mail(to: @email, subject: I18n.t('mailers.grant_reviewer_invitations.invite.subject', grant: @grant.name))
  end

  def reminder(invitation:, grant:)
    @email      = invitation.email
    @grant      = grant
    @inviter    = invitation.inviter

    mail(to: @email, subject: I18n.t('mailers.grant_reviewer_invitations.reminder.subject', grant: @grant.name))
  end
end
