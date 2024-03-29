require 'rails_helper'

RSpec.describe 'grant_reviewer_invitation requests', type: :request do
  let(:grant)   { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:inviter) { grant.admins.first }
  let(:email)   { Faker::Internet.email }
  let(:invited) { create(:grant_reviewer_invitation, grant: grant) }

  context 'invite' do
    context '#create' do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        login_user inviter
      end

      it 'mails the invitee' do
        post(invite_grant_reviewers_path(grant_id: grant.slug, params: { email: email }))
        expect(ActionMailer::Base.deliveries.count).to be 1
      end

      context 'invalid' do
        it 'does not mail when email was previously invited' do
          post(invite_grant_reviewers_path(grant_id: grant.slug, params: { email: invited.email }))
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
      end
    end
  end

  context 'reminder' do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      invited.save
      login_user inviter
    end

    context 'index of all open invitations' do
      it 'sends reminder mail to the invitee as part' do
        get(grant_invitation_reminders_path(grant))
        expect(ActionMailer::Base.deliveries.count).to be 1
      end

      it "updates the invitation's reminded_at attribute" do
        expect do
          get(grant_invitation_reminders_path(grant))
        end.to change{invited.reload.reminded_at}.from nil
      end
    end

    context 'one open invitation' do
      it 'sends reminder mail to the invitee as part' do
        get(grant_invitation_reminder_path(grant.id, invited))
        expect(ActionMailer::Base.deliveries.count).to be 1
      end

      it "updates the invitation's reminded_at attribute" do
        expect do
          get(grant_invitation_reminder_path(grant.id, invited))
        end.to change{invited.reload.reminded_at}.from nil
      end
    end

  end
end
