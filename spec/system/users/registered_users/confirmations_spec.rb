# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RegisteredUsers::Confirmations', type: :system, js: true do
  let(:saml_user)        { create(:saml_user) }
  let(:confirmed_user)   { create(:registered_user) }
  let(:unconfirmed_user) { create(:unconfirmed_user) }

  resend_button_text = 'Resend confirmation instructions'

  describe 'create' do
    describe 'existing users' do
      before(:each) do
        visit new_registered_user_confirmation_path
      end

      context 'unconfirmed user' do
        scenario 'resends confirmation' do
          page.fill_in 'Email', with: unconfirmed_user.email
          click_button resend_button_text
          expect(page).to have_content 'You will receive an email with instructions for how to confirm your email address'
        end
      end


      context 'confirmed user' do
        scenario 'does not resend ' do
          page.fill_in 'Email', with: confirmed_user.email
          click_button resend_button_text
          expect(page).to have_content 'Email was already confirmed, please try signing in'
        end
      end

      context 'saml_user' do
        scenario 'shows link to SSO log-in' do
          pending 'to be directed to log in via SSO'
          fail
        end
      end
    end
  end
end
