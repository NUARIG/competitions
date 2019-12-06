# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Users', type: :system do
  describe 'Index', js: true do
    before(:each) do
      @user1         = create(:user, last_name: 'BBBB',
                                     created_at: 65.minutes.ago,
                                     current_sign_in_at: 65.minutes.ago)
      @user2         = create(:user, last_name: 'AAAA',
                                     created_at: 1.month.ago,
                                     current_sign_in_at: 1.day.ago)
      @grant_creator = create(:grant_creator_user, last_name: 'ZZZZ',
                                                   created_at: 1.week.ago,
                                                   current_sign_in_at: 1.month.ago)
      @system_admin  = create(:system_admin_user, last_name: 'CCCC',
                                                  created_at: 1.year.ago)
    end

    describe 'Index' do
      context 'Policy' do
        scenario 'disallows anonymous user access' do
          visit users_path

          expect(page).not_to have_current_path(users_path) # redirects to login
        end

        scenario 'disallows user access' do
          login_as(@user1)
          visit users_path

          expect(page).to have_current_path(root_path)
          expect(page).to have_text authorization_error_text
        end

        scenario 'disallows grant_creator user access' do
          login_as(@grant_creator)
          visit users_path

          expect(page).to have_current_path(root_path)
          expect(page).to have_text authorization_error_text
        end

        scenario 'allows system_admin user access' do
          login_as(@system_admin)
          visit users_path

          expect(page).not_to have_text authorization_error_text
          expect(page).to have_text 'All Users'
        end
      end

      context 'Sorts' do
        before(:each) do
          login_as @system_admin
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
  end
end
