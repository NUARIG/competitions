require 'rails_helper'

RSpec.describe GrantReviewer::Invitation, type: :system do
  include ActionView::RecordIdentifier

  let!(:grant)                          { create(:published_open_grant_with_users) }
  let!(:admin)                          { grant.administrators.first }
  let!(:inviter)                        { grant.editors.first }
  let!(:saml_reviewer_invitation)       { create(:grant_reviewer_invitation,
                                                   :saml,
                                                   grant: grant,
                                                   inviter: inviter,
                                                   created_at: 1.day.ago) }
  let!(:registered_reviewer_invitation) { create(:grant_reviewer_invitation,
                                                   :registerable,
                                                   grant: grant,
                                                   inviter: inviter,
                                                   created_at: 1.day.ago) }

  let(:unknown_saml_user)               { build(:saml_user) }
  let(:unknown_registered_user)         { build(:registered_user, :unconfirmed) }

  let(:unknown_saml_invitation)         { create(:grant_reviewer_invitation, :saml,
                                                   grant: grant,
                                                   inviter: inviter,
                                                   email: unknown_saml_user.email,
                                                   created_at: 1.day.ago) }
  let(:unknown_registered_invitation)   { create(:grant_reviewer_invitation, :registerable,
                                                   grant: grant,
                                                   inviter: inviter,
                                                   email: unknown_registered_user.email,
                                                   created_at: 1.day.ago) }



  describe '#index', js: true  do
    before(:each) do
      login_as(admin, scope: :saml_user)
    end

    it 'includes the invited email' do
      visit grant_invitations_path(grant)
      expect(page).to have_content saml_reviewer_invitation.email
      expect(page).to have_content registered_reviewer_invitation.email
    end

    it 'includes the name of the inviter' do
      inviter_full_name = "#{inviter.first_name} #{inviter.last_name}"

      visit grant_invitations_path(grant)
      expect(find("tr[data-invite='#{registered_reviewer_invitation.id}']").text(:all)).to have_content inviter_full_name
      expect(find("tr[data-invite='#{saml_reviewer_invitation.id}']").text(:all)).to have_content inviter_full_name
    end

    context 'unconfirmed invites' do
      before(:each) do
        visit grant_invitations_path(grant)
      end

      it 'shows dash for unconfirmed invites' do
        registered_invite_row = find("tr[data-invite='#{registered_reviewer_invitation.id}']").text(:all)
        saml_invite_row       = find("tr[data-invite='#{saml_reviewer_invitation.id}']").text(:all)

        expect(registered_invite_row).to have_content '-'
        expect(saml_invite_row).to have_content '-'
      end

      it 'includes link to send reminder emails' do
        expect(page).to have_link 'Send Reminder to All Invited Reviewers', href: grant_invitation_reminders_path(grant)
      end

      it 'includes links to manage the invite' do
        registered_invite_row = find("tr[data-invite='#{registered_reviewer_invitation.id}']").text(:all)
        saml_invite_row       = find("tr[data-invite='#{saml_reviewer_invitation.id}']").text(:all)

        expect(registered_invite_row).to have_content 'Manage'
        expect(saml_invite_row).to have_content 'Manage'
      end

      it 'can be deleted' do
        invite_dom_id = "manage-#{dom_id(registered_reviewer_invitation)}"
        page.find("##{invite_dom_id}").hover

        accept_alert do
          click_link('Delete')
        end

        expect(page).to have_content "#{registered_reviewer_invitation.email} has been deleted"
      end

      it 'displays a reminder email confirmation message' do
        invite_dom_id = "manage-#{dom_id(saml_reviewer_invitation)}"
        page.find("##{invite_dom_id}").hover
        expect(page).to have_link('Send Reminder')
      end

      it 'displays a delete invitation confirmation message' do
        invite_dom_id = "manage-#{dom_id(saml_reviewer_invitation)}"
        page.find("##{invite_dom_id}").hover
        expect(page).to have_link('Delete')
      end
    end

    context 'confirmed invites' do
      before(:each) do
        registered_reviewer_invitation.update(confirmed_at: Time.now)
        saml_reviewer_invitation.update(confirmed_at: Time.now)
        visit grant_invitations_path(grant)
      end

      it 'includes the date of the confirmation' do
        registered_invite_row = find("tr[data-invite='#{registered_reviewer_invitation.id}']").text(:all)
        saml_invite_row       = find("tr[data-invite='#{saml_reviewer_invitation.id}']").text(:all)
        today_string          = Time.now.strftime("%m/%d/%Y")

        expect(registered_invite_row).not_to have_content '-'
        expect(registered_invite_row).to have_content today_string
        expect(saml_invite_row).not_to have_content '-'
        expect(registered_invite_row).to have_content today_string
      end

      it 'does not include link to send reminder emails' do
        expect(page).not_to have_link 'Send Reminder to Invited Reviewers', href: grant_invitation_reminders_path(grant)
      end

      it 'displays no email sent text' do
        visit grant_invitation_reminders_path(grant)
        expect(page).to have_text 'There are no open reviewer invitations for this grant. No reminders have been sent'
      end

      it 'does not include links to manage the invite' do
        registered_invite_row = find("tr[data-invite='#{registered_reviewer_invitation.id}']").text(:all)
        saml_invite_row       = find("tr[data-invite='#{saml_reviewer_invitation.id}']").text(:all)

        expect(registered_invite_row).not_to have_content 'Manage'
        expect(saml_invite_row).not_to have_content 'Manage'
      end
    end
  end

  describe '#create', js: true do
    before(:each) do
      login_as(admin, scope: :saml_user)
      visit grant_reviewers_path(grant)
    end

    scenario 'creates an invitation' do
      expect do
        page.fill_in 'Email', with: unknown_saml_user.email
        click_button 'Look Up'
        expect(page).to have_content("Could not find a user with the email: #{unknown_saml_user.email}")
        accept_alert do
          click_link 'Invite them to be a reviewer'
        end
        expect(page).to have_content "Invitation to #{unknown_saml_user.email} has been sent"
      end.to change{GrantReviewer::Invitation.count}.by 1
    end
  end

  describe '#update', js: true do
    before(:each) do
      unknown_registered_invitation.save
      visit new_registered_user_registration_path
      fill_in 'First Name', with: 'FirstName'
      fill_in 'Last Name', with: 'LastName'
      fill_in 'Email', with: unknown_registered_invitation.email
      fill_in 'Password', with: 'asdfasdf'
      fill_in 'registered_user_password_confirmation', with: 'asdfasdf'
      click_button 'Create My Account'
    end

    context 'paper trail', versioning: true do
      pending 'it tracks whodunnit' do
        fail 'not yet tracking update by new registered user'
        expect(unknown_registered_invitation.versions.last.whodunnit).to be unknown_registered_user
      end
    end
  end
end
