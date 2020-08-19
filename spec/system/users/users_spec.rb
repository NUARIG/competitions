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

  describe '#authenticate_user!' do
    context 'user not logged in' do
      scenario 'redirects to log in and displays error message' do
        visit new_grant_path
        expect(page).to have_content('You need to sign in or sign up before continuing.')
        expect(current_path).to eq(login_index_path)
      end
    end

    context 'user logged in' do
      scenario 'redirects to log in and displays error message' do
        registered_user = create(:registered_user)
        login_as(registered_user, scope: :registered_user)
        visit profile_path
        expect(page).to have_content('Your Profile')
        expect(current_path).to eq(profile_path)
      end
    end
  end
end