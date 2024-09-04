# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'SamlUsers', type: :system, js: true  do
  describe 'update' do
    let(:user)          { create(:saml_user, current_sign_in_at: Time.now) }
    let(:system_admin)  { create(:system_admin_saml_user) }
    let(:user2)         { create(:saml_user) }

    context 'system_admin' do
      before(:each) do
        login_as(system_admin, scope: :saml_user)

        visit(edit_user_path(user))
      end

      context 'success' do
        scenario 'can edit a user' do
          new_era_commons = Faker::Lorem.characters(number: 10)
          page.fill_in 'eRA Commons', with: new_era_commons
          click_button 'Update'
          expect(page).to have_content "#{full_name(user)}'s profile has been updated."
        end
      end

      context 'failure' do
        scenario 'shows error on failure' do
          user2_era_commons = Faker::Lorem.characters(number: 10)
          user2.update(era_commons: user2_era_commons)
          visit(edit_user_path(user))
          page.fill_in 'eRA Commons', with: user2_era_commons
          click_button 'Update'
          expect(page).to have_content 'eRA Commons has already been taken'
        end
      end
    end

    context 'user' do
      before(:each) do
        login_as(user, scope: :saml_user)

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
          visit(edit_user_path(user2))
          expect(page).to have_content 'You are not authorized to perform this action.'
        end
      end

      context 'failure' do
        scenario 'shows error on failure' do
          user2_era_commons = Faker::Lorem.characters(number: 10)
          user2.update(era_commons: user2_era_commons)
          visit(profile_path)
          page.fill_in 'eRA Commons', with: user2_era_commons
          click_button 'Update'
          expect(page).to have_content 'eRA Commons has already been taken'
        end
      end
    end

    context 'devise' do
      before(:each) do
        login_as(user, scope: :saml_user)
        visit(root_path)
      end

      scenario 'user signed in' do
        expect(page).to have_content("#{user.first_name} #{user.last_name}")
      end

      scenario 'user sign out' do
        page.find('#logged-in').hover
        click_button('Log Out')
        expect(page).to have_content('Log In')
      end
    end
  end
end
