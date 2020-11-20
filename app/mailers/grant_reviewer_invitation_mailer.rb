class GrantReviewerInvitationMailer < ApplicationMailer
  def invite(invitation:, grant:, inviter:)
    @email      = invitation.email
    @grant      = grant
    @login_url  = User.is_saml_email_address?(email: @email) ? login_index_url : new_registered_user_registration_url
    @inviter    = inviter

    mail(to: @email, subject: "Reviewer Invitation - #{@grant.name}")
  end
end
