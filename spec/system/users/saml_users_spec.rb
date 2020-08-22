# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'SamlUsers', type: :system, js: true  do
  describe 'update' do
    let(:user)          { create(:saml_user, current_sign_in_at: Time.now) }
    let(:system_admin)  { create(:system_admin_saml_user) }
    let(:other_user)    { create(:saml_user) }

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
end
