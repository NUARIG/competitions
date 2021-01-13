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
        login_as(system_admin, scope: :registered_user)

        visit(edit_user_path(user))
      end

      context 'success' do
        scenario 'can edit a user' do
          new_era_commons = Faker::Lorem.characters(number: 10)
          page.fill_in 'eRA Commons', with: new_era_commons
          click_button 'Update'
          expect(user.reload.era_commons).to eql new_era_commons
          expect(page).to have_content "#{full_name(user)}'s profile has been updated."
        end
      end

      context 'failure' do
        scenario 'shows error on failure' do
          other_user_era_commons = Faker::Lorem.characters(number: 10)
          other_user.update(era_commons: other_user_era_commons)
          visit(edit_user_path(user))
          page.fill_in 'eRA Commons', with: other_user_era_commons
          click_button 'Update'
          expect(page).to have_content 'eRA Commons has already been taken'
        end
      end
    end

    context 'user' do
      before(:each) do
        login_as(user, scope: :registered_user)

        visit(profile_path)
      end

      context 'success' do
        scenario 'can edit own profile' do
          new_era_commons = Faker::Lorem.characters(number: 10)
          page.fill_in 'eRA Commons', with: new_era_commons
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
          other_user.update(era_commons: other_user_era_commons)
          visit(profile_path)
          page.fill_in 'eRA Commons', with: other_user_era_commons
          click_button 'Update'
          expect(page).to have_content 'eRA Commons has already been taken'
        end
      end
    end
  end

  describe 'sign up new user' do
    scenario 'without pending grant reviewer invitation' do
      visit new_registered_user_registration_path
      fill_in_new_user_form
      expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
    end

    scenario 'with pending grant reviewer invitation' do
      pending_invite = create(:grant_reviewer_invitation, email: 'email@example.com')
      visit new_registered_user_registration_path
      fill_in_new_user_form
      expect(page).to have_content I18n.t('devise.registrations.signed_up')
      expect(page).to have_content "You have been added as a reviewer to #{pending_invite.grant.name}"
      expect(page.find('.warning')).to have_link pending_invite.grant.name, href: grant_path(pending_invite.grant)
    end
  end

  describe 'sign in registered user' do
    scenario 'user sign in' do
      @user3 = create(:registered_user, email: 'user3@example.com', password: 'password')
      visit login_index_path
      page.fill_in('registered_user_uid', with: @user3.email)
      page.fill_in('registered_user_password', with: 'password')
      click_button 'Log in'
      expect(page).to have_content("#{@user3.first_name} #{@user3.last_name}")
    end
  end

  def fill_in_new_user_form
    page.fill_in 'First Name', with: 'FirstName'
    page.fill_in 'Last Name', with: 'LastName'
    page.fill_in 'Email', with: 'email@example.com'
    page.fill_in 'Password', with: 'password'
    page.fill_in 'Password confirmation', with: 'password'
    click_button 'Create My Account'
  end
end
