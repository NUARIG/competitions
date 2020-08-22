# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'RegisteredUsers', type: :system, js: true  do
  describe 'update' do
    let(:user)          { create(:registered_user, current_sign_in_at: Time.now) }
    let(:system_admin)  { create(:system_admin_registered_user) }
    let(:other_user)    { create(:registered_user) }

    context 'system_admin' do
      before(:each) do
        login_user(system_admin)

        visit(edit_user_path(user))
      end

      context 'success' do
        scenario 'can edit a user' do
          new_era_commons = Faker::Lorem.characters(number: 10)
          find_field('eRA Commons').set(new_era_commons)
          click_button 'Update'
          expect(user.reload.era_commons).to eql new_era_commons
          expect(page).to have_content "#{full_name(user)}'s profile has been updated."
        end
      end

      context 'failure' do
        scenario 'shows error on failure' do
          other_user_era_commons = Faker::Lorem.characters(number: 10)
          other_user.update_attribute(:era_commons, other_user_era_commons)
          visit(edit_user_path(user))
          find_field('eRA Commons').set(other_user_era_commons)
          click_button 'Update'
          expect(page).to have_content 'eRA Commons has already been taken'
        end
      end
    end

    context 'user' do
      before(:each) do
        login_user(user)

        visit(profile_path)
      end

      context 'success' do
        scenario 'can edit own profile' do
          new_era_commons = Faker::Lorem.characters(number: 10)
          find_field('eRA Commons').set(new_era_commons)
          click_button 'Update'
          expect(user.reload.era_commons).to eql new_era_commons
          expect(page).to have_content 'Your profile has been updated.'
        end

        scenario 'cannot edit another user profile' do
          visit(edit_user_path(other_user))
          expect(page).to have_content 'You are not authorized to perform this action.'
        end
      end

      context 'failure' do
        scenario 'shows error on failure' do
          other_user_era_commons = Faker::Lorem.characters(number: 10)
          other_user.update_attribute(:era_commons, other_user_era_commons)
          visit(profile_path)
          find_field('eRA Commons').set(other_user_era_commons)
          click_button 'Update'
          expect(page).to have_content 'eRA Commons has already been taken'
        end
      end
    end
  end

  describe 'sign up new user' do
    scenario 'sign up new user with devise interface' do
      visit new_registered_user_registration_path
      find_field('First Name').set('FirstName')
      find_field('Last Name').set('LastName')
      find_field('Email').set('email@example.com')
      find_field('Password').set('password')
      find_field('Password confirmation').set('password')
      click_button 'Sign up'
      expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    end

    scenario 'user sign in' do
      @user3 = create(:registered_user, email: 'user3@example.com', password: 'password')
      visit new_registered_user_session_path
      find_field('Email').set('user3@example.com')
      find_field('Password').set('password')
      click_button 'Log in'
      expect(page).to have_content("#{@user3.first_name} #{@user3.last_name}")
    end
  end
end
