require 'rails_helper'

RSpec.describe Devise::Mailer, type: :mailer do
  describe 'devise mailers' do
    describe 'confirmation instructions' do
      let(:user) { create(:unconfirmed_user) }
      let(:mail) { Devise::Mailer.confirmation_instructions(user, user.confirmation_token) }

      it 'renders the password reset instructions email' do
        expect(mail.subject).to eq ('Confirmation instructions')
        expect(mail.to.first).to eq(user.email)
        expect(mail.from.first).to eq(COMPETITIONS_CONFIG[:mailer][:email])
        expect(mail.body.encoded).to include COMPETITIONS_CONFIG[:application_name]
      end
    end

    describe 'password reset instructions' do
      let(:user) { create(:registered_user, email: 'test_to@test.com', reset_password_token: '1234567890') }
      let(:mail) { Devise::Mailer.reset_password_instructions(user, user.reset_password_token) }

      it 'renders the password reset instructions email' do
        expect(mail.subject).to eq ('Reset password instructions')
        expect(mail.to.first).to eq(user.email)
        expect(mail.from.first).to eq(COMPETITIONS_CONFIG[:mailer][:email])
        expect(mail.body.encoded).to include COMPETITIONS_CONFIG[:application_name]
      end
    end

    describe 'password changed email' do
      let(:user) { create(:registered_user, email: 'test_to@test.com') }
      let(:mail) { Devise::Mailer.password_change(user) }

      it 'renders the password reset instructions email' do
        expect(mail.subject).to eq ('Password Changed')
        expect(mail.to.first).to eq(user.email)
        expect(mail.from.first).to eq(COMPETITIONS_CONFIG[:mailer][:email])
        expect(mail.body.encoded).to include COMPETITIONS_CONFIG[:application_name]
      end
    end

    describe 'password changed email' do
      let(:user) { create(:registered_user, email: 'test_to@test.com') }
      let(:mail) { Devise::Mailer.email_changed(user) }

      it 'renders the password reset instructions email' do
        expect(mail.subject).to eq ('Email Changed')
        expect(mail.to.first).to eq(user.email)
        expect(mail.from.first).to eq(COMPETITIONS_CONFIG[:mailer][:email])
        expect(mail.body.encoded).to include COMPETITIONS_CONFIG[:application_name]
      end
    end
  end
end
