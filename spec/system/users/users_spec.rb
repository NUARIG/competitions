# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Users', type: :system, js: true  do
  describe '#index' do
    before(:each) do
      @user1         = create(:saml_user, last_name: 'BBBB',
                                     created_at: 65.minutes.ago,
                                     current_sign_in_at: 65.minutes.ago)
      @user2         = create(:saml_user, last_name: 'AAAA',
                                     created_at: 1.month.ago,
                                     current_sign_in_at: 1.day.ago)
      @grant_creator = create(:grant_creator_saml_user, last_name: 'ZZZZ',
                                                   created_at: 1.week.ago,
                                                   current_sign_in_at: 1.month.ago)
      @system_admin  = create(:system_admin_saml_user, last_name: 'CCCC',
                                                  created_at: 1.year.ago)
    end

    context 'Sorts' do
      before(:each) do
        login_as(@system_admin, scope: :saml_user)
        visit users_path

        @system_admin.update_attribute(:current_sign_in_at, 45.days.ago)
        @system_admin.save!
      end

      scenario 'default sort by current_sign_in_at' do
        visit users_path
        within 'tr.user:nth-child(1)' do
          expect(page).to have_text "#{sortable_full_name(@user1)} #{@user1.email}"
        end
        within 'tr.user:nth-child(2)' do
          expect(page).to have_text "#{sortable_full_name(@user2)} #{@user2.email}"
        end
        within 'tr.user:nth-child(3)' do
          expect(page).to have_text "#{sortable_full_name(@grant_creator)} #{@grant_creator.email}"
        end
        within 'tr.user:nth-child(4)' do
          expect(page).to have_text "#{sortable_full_name(@system_admin)} #{@system_admin.email}"
        end
      end

      scenario 'reverse sort by current_sign_in_at' do
        visit users_path
        click_on('Last Access')
        within 'tr.user:nth-child(4)' do
          expect(page).to have_text "#{sortable_full_name(@user1)} #{@user1.email}"
        end
        within 'tr.user:nth-child(3)' do
          expect(page).to have_text "#{sortable_full_name(@user2)} #{@user2.email}"
        end
        within 'tr.user:nth-child(2)' do
          expect(page).to have_text "#{sortable_full_name(@grant_creator)} #{@grant_creator.email}"
        end
        within 'tr.user:nth-child(1)' do
          expect(page).to have_text "#{sortable_full_name(@system_admin)} #{@system_admin.email}"
        end
      end

      scenario 'sort by created_at' do
        @user1.update_attribute(:created_at, 3.weeks.ago)
        @user2.update_attribute(:created_at, 1.day.ago)
        @grant_creator.update_attribute(:created_at, 1.year.ago)
        @system_admin.update_attribute(:created_at, 181.days.ago)

        visit users_path
        click_on('Joined')
        within 'tr.user:nth-child(4)' do
          expect(page).to have_text "#{sortable_full_name(@user2)} #{@user2.email}"
        end
        within 'tr.user:nth-child(3)' do
          expect(page).to have_text "#{sortable_full_name(@user1)} #{@user1.email}"
        end
        within 'tr.user:nth-child(2)' do
          expect(page).to have_text "#{sortable_full_name(@system_admin)} #{@system_admin.email}"
        end
        within 'tr.user:nth-child(1)' do
          expect(page).to have_text "#{sortable_full_name(@grant_creator)} #{@grant_creator.email}"
        end

        click_on('Joined')
        within 'tr.user:nth-child(1)' do
          expect(page).to have_text "#{sortable_full_name(@user2)} #{@user2.email}"
        end
        within 'tr.user:nth-child(2)' do
          expect(page).to have_text "#{sortable_full_name(@user1)} #{@user1.email}"
        end
        within 'tr.user:nth-child(3)' do
          expect(page).to have_text "#{sortable_full_name(@system_admin)} #{@system_admin.email}"
        end
        within 'tr.user:nth-child(4)' do
          expect(page).to have_text "#{sortable_full_name(@grant_creator)} #{@grant_creator.email}"
        end
      end
    end
  end

  describe 'update' do
    let(:user)          { create(:saml_user, current_sign_in_at: Time.now) }
    let(:system_admin)  { create(:system_admin_saml_user) }
    let(:other_user)    { create(:saml_user) }

    context 'system_admin' do
      before(:each) do
        login_as(system_admin, scope: :saml_user)

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
        login_as(user, scope: :saml_user)

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
