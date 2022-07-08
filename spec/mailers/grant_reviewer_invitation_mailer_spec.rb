require 'rails_helper'
include UsersHelper

RSpec.describe GrantReviewerInvitationMailer, type: :mailer do
  context 'invite' do
    let(:saml_invite)         { create(:grant_reviewer_invitation, :saml) }
    let(:registerable_invite) { create(:grant_reviewer_invitation, :registerable) }
    let(:saml_mailer)         { described_class.invite(invitation:  saml_invite,
                                                        grant:      saml_invite.grant,
                                                        inviter:    saml_invite.inviter) }
    let(:registerable_mailer) { described_class.invite(invitation:  registerable_invite,
                                                        grant:      registerable_invite.grant,
                                                        inviter:    registerable_invite.inviter) }

    def application_name
      COMPETITIONS_CONFIG[:application_name]
    end

    context 'saml invitee' do
      it 'uses the invitee email' do
        expect(saml_mailer.to).to eql [saml_invite.email]
      end

      it 'uses the grant name in the subject' do
        expect(saml_mailer.subject).to include saml_invite.grant.name
      end


      context 'body' do
        it 'includes the inviter name and email address' do
          expect(saml_mailer.body.encoded).to include CGI.escapeHTML("#{saml_invite.inviter.first_name} #{saml_invite.inviter.last_name}")
          expect(saml_mailer.body.encoded).to include saml_invite.inviter.email
        end

        it 'includes the login url' do
          expect(saml_mailer.body.encoded).to have_link application_name, href: login_index_url
        end
      end
    end

    context 'registerable invitee' do
      it 'uses the invitee email' do
        expect(registerable_mailer.to).to eql [registerable_invite.email]
      end

      context 'body' do
        it 'includes the inviter name and email address' do
          expect(registerable_mailer.body.encoded).to include CGI.escapeHTML("#{registerable_invite.inviter.first_name} #{registerable_invite.inviter.last_name}")
          expect(registerable_mailer.body.encoded).to include registerable_invite.inviter.email
        end

        it 'includes the new registerable url' do
          expect(registerable_mailer.body.encoded).to have_link application_name, href: new_registered_user_registration_url
        end
      end
    end
  end
end
