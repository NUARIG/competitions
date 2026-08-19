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

      context 'Competitions' do
        let!(:admin_grant)      { create(:published_open_grant) }
        let!(:editor_grant)     { create(:draft_closed_grant) }
        let!(:deleted_grant)    { create(:published_closed_grant) }

        let!(:admin_permission)  { create(:grant_permission, grant: admin_grant,   user: saml_user1, role: 'admin') }
        let!(:editor_permission) { create(:grant_permission, grant: editor_grant,  user: saml_user1, role: 'editor') }
        let!(:viewer_permission) { create(:grant_permission, grant: admin_grant,   user: saml_user2, role: 'viewer') }
        let!(:deleted_permission) { create(:grant_permission, grant: deleted_grant, user: saml_user2, role: 'admin') }

        before(:each) do
          create(:panel, grant: deleted_grant)
          deleted_grant.discard
          login_as(saml_system_admin, scope: :saml_user)
          visit users_path
        end

        scenario 'lists every competition a user is on and the role held on it' do
          within "tr#user-#{saml_user1.id}" do
            expect(page).to have_link(admin_grant.name,  href: grant_path(admin_grant))
            expect(page).to have_text("#{admin_grant.name} (Admin)")
            expect(page).to have_link(editor_grant.name, href: grant_path(editor_grant))
            expect(page).to have_text("#{editor_grant.name} (Editor)")
          end

          within "tr#user-#{saml_user2.id}" do
            expect(page).to have_text("#{admin_grant.name} (Viewer)")
          end
        end

        scenario 'omits competitions the user is not on' do
          within "tr#user-#{saml_user1.id}" do
            expect(page).not_to have_text(deleted_grant.name)
          end
        end

        scenario 'omits deleted competitions' do
          within "tr#user-#{saml_user2.id}" do
            expect(page).not_to have_text(deleted_grant.name)
          end
        end

        scenario 'shows no competitions for a user without grant permissions' do
          within "tr#user-#{registered_user.id}" do
            expect(page).not_to have_text(admin_grant.name)
            expect(page).not_to have_text(editor_grant.name)
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
end
