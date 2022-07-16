# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'RegisteredUsers::Passwords', type: :system, js: true  do
  let(:valid_password)  { Faker::Lorem.characters(number: rand(Devise.password_length)) }
  let(:saml_user)       { create(:saml_user) }
  let(:registered_user) { create(:registered_user) }

  describe 'create' do
    before(:each) do
      visit new_registered_user_password_path
    end

    describe 'existing users' do
      context 'registered_user' do
        scenario 'has form' do
          find_field('Email').set(registered_user.email)
          click_button('Reset Password')
          expect(page).to have_content 'You will receive an email with instructions on how to reset your password in a few minutes.'
        end
      end
    end

    describe 'unknown user' do
      scenario 'is prompted to create an account' do
        find_field('Email').set(Faker::Internet.email)
        click_button('Reset Password')
        expect(page).to have_content 'Email not found'
      end
    end
  end

  describe 'update' do
    describe 'existing users' do
      let(:token) { registered_user.send_reset_password_instructions }

      context 'user not logged in' do
        scenario 'displays error with invalid token' do
          visit edit_registered_user_password_path(params: {reset_password_token: Faker::Lorem.characters(number: 5)})
          page.fill_in 'New password', with: valid_password
          page.fill_in 'Confirm new password', with: valid_password
          click_button 'Change my password'
          expect(page).to have_content 'token is invalid'
        end

        scenario 'can change using password reset' do
          visit edit_registered_user_password_path(params: {reset_password_token: token})
          page.fill_in 'New password', with: valid_password
          page.fill_in 'Confirm new password', with: valid_password
          click_button 'Change my password'
          expect(page).to have_content 'Your password has been changed successfully.'
        end
      end

      context 'user logged in' do
        context 'saml user' do
          before(:each) do
            login_as(saml_user, scope: :saml_user)
          end

          scenario 'change Your Password link not on SAML user profiles' do
            visit profile_path(saml_user)
            expect(page).not_to have_content 'Change Your Password'
          end

          scenario 'visiting registration page redirects to root' do
            visit profile_path(saml_user)
            visit edit_registered_user_registration_path
            expect(page).not_to have_content 'Change Your Password'
            expect(page).to have_content 'You are already logged in.'
            expect(current_path).to eq root_path
          end

          scenario 'visiting password reset page redirects to root' do
            visit new_registered_user_confirmation_path
            expect(page).to have_current_path(root_path)
            expect(page).to have_content 'You are already logged in.'
          end
        end

        context 'registered user' do
          before(:each) do
            login_as(registered_user, scope: :registered_user)
          end

          scenario 'user can navigate to password change from profile' do
            visit profile_path(registered_user)
            click_link 'Change Your Password'
            expect(current_path).to eq edit_registered_user_registration_path
          end

          scenario 'can change password while logged in' do
            new_password = Faker::Lorem.characters(number: 12, min_alpha: 6)
            visit edit_registered_user_registration_path(registered_user)
            find(:css, "#registered_user_current_password").set(registered_user.password)
            find(:css, "#registered_user_password").set(new_password)
            find(:css, "#registered_user_password_confirmation").set(new_password)
            click_button 'Update'
            expect(page).to have_content 'Your account has been updated successfully.'
          end
        end
      end
    end
  end
end
