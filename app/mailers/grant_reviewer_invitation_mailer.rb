class GrantReviewerInvitationMailer < ApplicationMailer
  def invite(invitation:, grant:, inviter:)
    @email      = invitation.email
    @grant      = grant
    @login_url  = get_login_url_by_email_address(@email)
    @inviter    = inviter

    mail(to: @email, subject: I18n.t('mailers.grant_reviewer_invitations.invite.subject', grant: @grant.name))
  end

  def reminder(invitation:, grant:)
    @email      = invitation.email
    @grant      = grant
    @login_url  = get_login_url_by_email_address(@email)
    @inviter    = invitation.inviter

    mail(to: @email, subject: I18n.t('mailers.grant_reviewer_invitations.reminder.subject', grant: @grant.name))
  end

  private

  def get_login_url_by_email_address(email)
    User.is_saml_email_address?(email: email) ? login_index_url : new_registered_user_registration_url
  end
end
