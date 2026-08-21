# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Users', type: :system, js: true  do

  SAMLUSER_TEXT = 'SAML User'
  REGISTEREDUSER_TEXT = 'Registered User'

  let!(:saml_user1) { create(:saml_user, last_name: 'Bbbb', created_at: 65.minutes.ago, current_sign_in_at: 65.minutes.ago) }
  let!(:saml_user2) { create(:saml_user, last_name: 'Aaaa', created_at: 1.month.ago, current_sign_in_at: 1.day.ago) }
  let!(:saml_grant_creator) { create(:grant_creator_saml_user, last_name: 'Zzzz', created_at: 1.month.ago, current_sign_in_at: 1.month.ago) }
  let!(:saml_system_admin) { create(:system_admin_saml_user, last_name: 'Cccc', created_at: 1.year.ago, current_sign_in_at: 45.days.ago ) }
  let!(:registered_user) { create(:registered_user, last_name: 'Rrrr', created_at: 5.days.ago, current_sign_in_at: 5.days.ago) }
  let!(:registered_grant_creator) { create(:grant_creator_registered_user, last_name: 'Ssss', created_at: 2.months.ago, current_sign_in_at: 2.months.ago) }
  let!(:registered_system_admin) { create(:system_admin_registered_user, last_name: 'Tttt', created_at: 1.year.ago, current_sign_in_at: 1.year.ago) }
  let(:unconfirmed_registered_user) { create(:registered_user, last_name: 'Vvvv', created_at: 5.minutes.ago, current_sign_in_at: nil) }

  describe '#index' do
    describe '#index' do
      context 'Sorts' do
        before(:each) do
          # In the real world, the current admin will always have the most recent current_sign_in_at
          login_as(saml_system_admin, scope: :saml_user)
        end

        context 'current_sign_in_at' do
          before(:each) do
            unconfirmed_registered_user.touch
            visit users_path
          end

          scenario 'default sort by current_sign_in_at, unconfirmed last' do
            within 'tr.user:nth-child(1)' do
              expect(page).to have_text "#{sortable_full_name(saml_system_admin)} #{saml_system_admin.email}" # CCC
            end
            within 'tr.user:nth-child(2)' do
              expect(page).to have_text "#{sortable_full_name(saml_user1)} #{saml_user1.email}" # BBB
            end
            within 'tr.user:nth-child(3)' do
              expect(page).to have_text "#{sortable_full_name(saml_user2)} #{saml_user2.email}" # AAA
            end
            within 'tr.user:nth-child(4)' do
              expect(page).to have_text "#{sortable_full_name(registered_user)} #{registered_user.email}" # 5 days
            end
            within 'tr.user:nth-child(5)' do
              expect(page).to have_text "#{sortable_full_name(saml_grant_creator)} #{saml_grant_creator.email}" # 1 month ago
            end
            within 'tr.user:nth-child(6)' do
              expect(page).to have_text "#{sortable_full_name(registered_grant_creator)} #{registered_grant_creator.email}" # Sss
            end
            within 'tr.user:nth-child(7)' do
              expect(page).to have_text "#{sortable_full_name(registered_system_admin)} #{registered_system_admin.email}" # Ttt
            end
            within 'tr.user:nth-child(8)' do
              expect(page).to have_text "#{sortable_full_name(unconfirmed_registered_user)} #{unconfirmed_registered_user.email}" # VVV
            end
          end

          scenario 'reverse sort by current_sign_in_at, unconfirmed last' do
            click_on(I18n.t('activerecord.attributes.user.current_sign_in_at'))
            pause
            within 'tr.user:nth-child(8)' do
              expect(page).to have_text "#{sortable_full_name(unconfirmed_registered_user)} #{unconfirmed_registered_user.email}" # VVV
            end
            within 'tr.user:nth-child(7)' do
              expect(page).to have_text "#{sortable_full_name(saml_system_admin)} #{saml_system_admin.email}" # CCC
            end
            within 'tr.user:nth-child(6)' do
              expect(page).to have_text "#{sortable_full_name(saml_user1)} #{saml_user1.email}" # BBB
            end
            within 'tr.user:nth-child(5)' do
              expect(page).to have_text "#{sortable_full_name(saml_user2)} #{saml_user2.email}" # AAA
            end
            within 'tr.user:nth-child(4)' do
              expect(page).to have_text "#{sortable_full_name(registered_user)} #{registered_user.email}" # 5 days
            end
            within 'tr.user:nth-child(3)' do
              expect(page).to have_text "#{sortable_full_name(saml_grant_creator)} #{saml_grant_creator.email}" # 1 month ago
            end
            within 'tr.user:nth-child(2)' do
              expect(page).to have_text "#{sortable_full_name(registered_grant_creator)} #{registered_grant_creator.email}" # Sss
            end
            within 'tr.user:nth-child(1)' do
              expect(page).to have_text "#{sortable_full_name(registered_system_admin)} #{registered_system_admin.email}" # Ttt
            end
          end
        end

        scenario 'sort by created_at' do
          saml_user1.update(created_at: 3.weeks.ago)
          saml_user2.update(created_at: 1.day.ago)
          saml_grant_creator.update(created_at: 3.year.ago)
          saml_system_admin.update(created_at: 181.days.ago)
          registered_user.update(created_at: 8.days.ago)
          registered_grant_creator.update(created_at: 3.month.ago)
          registered_system_admin.update(created_at: 2.years.ago)
          visit users_path
          click_on('Date Joined')
          pause

          within 'tr.user:nth-child(7)' do
            expect(page).to have_text "#{sortable_full_name(saml_user2)} #{saml_user2.email}"
          end
          within 'tr.user:nth-child(6)' do
            expect(page).to have_text "#{sortable_full_name(registered_user)} #{registered_user.email}"
          end
          within 'tr.user:nth-child(5)' do
            expect(page).to have_text "#{sortable_full_name(saml_user1)} #{saml_user1.email}"
          end
          within 'tr.user:nth-child(4)' do
            expect(page).to have_text "#{sortable_full_name(registered_grant_creator)} #{registered_grant_creator.email}"
          end
          within 'tr.user:nth-child(3)' do
            expect(page).to have_text "#{sortable_full_name(saml_system_admin)} #{saml_system_admin.email}"
          end
          within 'tr.user:nth-child(2)' do
            expect(page).to have_text "#{sortable_full_name(registered_system_admin)} #{registered_system_admin.email}"
          end
          within 'tr.user:nth-child(1)' do
            expect(page).to have_text "#{sortable_full_name(saml_grant_creator)} #{saml_grant_creator.email}"
          end

          click_on('Joined')
          pause
          within 'tr.user:nth-child(1)' do
            expect(page).to have_text "#{sortable_full_name(saml_user2)} #{saml_user2.email}"
          end
          within 'tr.user:nth-child(2)' do
            expect(page).to have_text "#{sortable_full_name(registered_user)} #{registered_user.email}"
          end
          within 'tr.user:nth-child(3)' do
            expect(page).to have_text "#{sortable_full_name(saml_user1)} #{saml_user1.email}"
          end
          within 'tr.user:nth-child(4)' do
            expect(page).to have_text "#{sortable_full_name(registered_grant_creator)} #{registered_grant_creator.email}"
          end
          within 'tr.user:nth-child(5)' do
            expect(page).to have_text "#{sortable_full_name(saml_system_admin)} #{saml_system_admin.email}"
          end
          within 'tr.user:nth-child(6)' do
            expect(page).to have_text "#{sortable_full_name(registered_system_admin)} #{registered_system_admin.email}"
          end
          within 'tr.user:nth-child(7)' do
            expect(page).to have_text "#{sortable_full_name(saml_grant_creator)} #{saml_grant_creator.email}"
          end
        end

        context 'user type' do
          scenario 'sort by type' do
            unconfirmed_registered_user.touch
            visit users_path

            click_on(I18n.t('activerecord.attributes.user.type'))
            pause

            within 'tr.user:nth-child(1)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
            end
            within 'tr.user:nth-child(2)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
            end
            within 'tr.user:nth-child(3)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
            end

            within 'tr.user:nth-child(4)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
              expect(page).to have_text "#{sortable_full_name(unconfirmed_registered_user)}"
            end
            within 'tr.user:nth-child(5)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(6)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(7)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(8)' do
              expect(page).to have_text SAMLUSER_TEXT
            end

            click_on(I18n.t('activerecord.attributes.user.type'))
            pause

            within 'tr.user:nth-child(1)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(2)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(3)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(4)' do
              expect(page).to have_text SAMLUSER_TEXT
            end
            within 'tr.user:nth-child(5)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
            end
            within 'tr.user:nth-child(6)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
            end
            within 'tr.user:nth-child(7)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
            end
            within 'tr.user:nth-child(8)' do
              expect(page).to have_text REGISTEREDUSER_TEXT
              expect(page).to have_text "#{sortable_full_name(unconfirmed_registered_user)}"
            end
          end
        end
      end

      describe 'authenticate_user!' do
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
  end

  describe '#edit' do
    let(:system_admin) { create(:system_admin_saml_user) }
    let(:target_user) { create(:saml_user) }

    before(:each) do
      login_as(system_admin, scope: :saml_user)
    end

    context 'grant permissions section' do
      scenario 'shows grant permissions table with expected columns and values' do
        grant = create(:grant, :draft, name: 'Alpha Grant', publish_date: 10.days.from_now.to_date)
        create(:grant_permission, grant: grant, user: target_user, role: 'editor')

        visit edit_user_path(target_user)

        expect(page).to have_content 'Grant Permissions'
        within 'turbo-frame#user_grant_permissions' do
          expect(page).to have_table
          expect(page).to have_content 'Grant Name'
          expect(page).to have_content 'Status'
          expect(page).to have_content 'Role'
          expect(page).to have_content 'Publish Date'
          expect(page).to have_content 'Alpha Grant'
          expect(page).to have_content 'Draft'
          expect(page).to have_content 'Editor'
        end
      end

      scenario 'shows empty state when no grant permissions exist' do
        visit edit_user_path(target_user)

        expect(page).to have_content 'Grant Permissions'
        within 'turbo-frame#user_grant_permissions' do
          expect(page).to have_content 'No grant permissions found for this user.'
        end
      end

      scenario 'orders permissions by publish date desc then grant name asc' do
        newest_a = create(:grant, :published, name: 'A Latest', publish_date: 9.days.from_now.to_date)
        newest_b = create(:grant, :published, name: 'B Latest', publish_date: 9.days.from_now.to_date)
        older = create(:grant, :published, name: 'Older Grant', publish_date: 8.days.from_now.to_date)

        create(:grant_permission, grant: older, user: target_user, role: 'viewer')
        create(:grant_permission, grant: newest_b, user: target_user, role: 'admin')
        create(:grant_permission, grant: newest_a, user: target_user, role: 'editor')

        visit edit_user_path(target_user)

        within 'turbo-frame#user_grant_permissions' do
          expect(page).to have_content 'A Latest'
          rows = all('table tbody tr').map(&:text)
          expect(rows[0]).to include('A Latest')
          expect(rows[1]).to include('B Latest')
          expect(rows[2]).to include('Older Grant')
        end
      end

      scenario 'shows five grant permissions per page and paginates to additional results' do
        grants = 6.times.map do |i|
          create(:grant, :published,
                 name: "Grant #{i + 1}",
                 publish_date: (9 - i).days.from_now.to_date)
        end

        grants.each do |grant|
          create(:grant_permission, grant: grant, user: target_user, role: 'viewer')
        end

        visit edit_user_path(target_user)

        within 'turbo-frame#user_grant_permissions' do
          expect(all('table tbody tr').size).to eq(5)
          expect(page).to have_content('Grant 1')
          expect(page).to have_content('Grant 5')
          expect(page).not_to have_content('Grant 6')

          click_link '2'

          expect(page).to have_content('Grant 6')
          expect(page).not_to have_content('Grant 1')
          expect(all('table tbody tr').size).to eq(1)
        end
      end
    end
  end
end
