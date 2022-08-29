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
    end

    context 'logged in users' do
      describe 'saml_user' do
        scenario 'redirects to root path and shows flash message' do
          saml_user = create(:saml_user)
          login_as(saml_user, scope: :saml_user)
          visit new_registered_user_confirmation_path
          expect(page).to have_current_path(root_path)
          expect(page).to have_content 'You are already logged in.'
        end
      end

      describe 'registered_user' do
        scenario 'redirects to root path and shows flash message' do
          registered_user = create(:registered_user)
          login_as(registered_user, scope: :registered_user)
          visit new_registered_user_confirmation_path
          expect(page).to have_current_path(new_registered_user_confirmation_path)
        end
      end
    end
  end
end
