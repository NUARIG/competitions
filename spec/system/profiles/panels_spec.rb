require 'rails_helper'
include UsersHelper

RSpec.describe 'Profile Panels', type: :system, js: :true do
  let(:user)             { create(:user)}
  let!(:editor_grant)    { create(:open_grant_with_users_and_form_and_submission_and_reviewer, name: "AAA Editor #{Faker::Lorem.sentence}") }
  let!(:reviewer_grant)  { create(:closed_grant_with_users_and_form_and_submission_and_reviewer, name: "ZZZ Reviewer #{Faker::Lorem.sentence}") }
  let!(:submitted_grant) { create(:closed_grant_with_users_and_form_and_submission_and_reviewer, name: "YYY Applicant #{Faker::Lorem.sentence}") }
  let!(:draft_grant)     { create(:draft_open_grant_with_users_and_form_and_submission_and_reviewer, name: "BBB Draft #{Faker::Lorem.sentence}") }

  let!(:editor_permission)            { create(:grant_permission, grant: editor_grant, user: user, role: 'editor') }
  let!(:reviewer_role)                { create(:grant_reviewer, grant: reviewer_grant, reviewer: user) }
  let!(:draft_permission)             { create(:grant_permission, grant: draft_grant, user: user, role: 'admin') }
  let!(:grant_submission_submission)  { create(:submission_with_responses, grant: submitted_grant, applicant: user ) }

  context 'user without panels' do
    context 'header text' do
      context 'excludes MyPanels' do
        scenario 'applicant with no roles' do
          login_user editor_grant.applicants.first
          visit root_path

          expect(page).not_to have_link 'MyPanels'
        end

        scenario 'anonymous user' do
          visit root_path

          expect(page).not_to have_link 'MyPanels'
        end
      end
    end

    context '#index' do
      scenario 'displays no panels message' do
        login_user editor_grant.applicants.first
        visit profile_panels_path
        expect(page).to have_content 'You have no scheduled Review Panels at this time.'
      end
    end
  end

  context 'user with panels' do
    before(:each) do
      login_user user
    end

    context 'header text' do
      scenario 'includes MyPanels' do
        visit root_path

        expect(page).to have_link('MyPanels', href: profile_panels_path)
      end
    end

    context '#index' do
      scenario 'includes editable and reviewable grants' do
        visit profile_panels_path

        expect(page).to have_link(editor_grant.name, href: grant_panel_path(editor_grant))
        expect(page).to have_link(reviewer_grant.name, href: grant_panel_path(reviewer_grant))
      end

      scenario 'does not include draft grant or submitted grant' do
        visit profile_panels_path

        expect(page).not_to have_link(submitted_grant.name, href: grant_panel_path(submitted_grant))
        expect(page).not_to have_link(draft_grant.name, href: grant_panel_path(draft_grant))
      end

      scenario 'excludes draft grant or submitted grant' do
        visit profile_panels_path

        expect(page).not_to have_link(submitted_grant.name, href: grant_panel_path(submitted_grant))
        expect(page).not_to have_link(draft_grant.name, href: grant_panel_path(draft_grant))
      end

      scenario 'excludes grant with unscheduled panel' do
        editor_grant.panel.update!(start_datetime: nil, end_datetime: nil)
        visit profile_panels_path

        expect(page).not_to have_link(editor_grant.name, href: grant_panel_path(editor_grant))
        expect(page).to have_link(reviewer_grant.name, href: grant_panel_path(reviewer_grant))
      end

      context '#sorts' do
        before(:each) do
          reviewer_grant.update!(review_open_date: 4.days.from_now, review_close_date: 5.days.from_now)
          reviewer_grant.panel.update!(start_datetime: 1.year.from_now, end_datetime: 1.year.from_now + 2.hours)
          editor_grant.update!(review_open_date: 2.days.from_now, review_close_date: 3.days.from_now)
        end

        scenario 'default sort on panel time descending' do
          visit profile_panels_path

          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text reviewer_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text editor_grant.name
          end
        end

        scenario 'reverse sorts on panel time' do
          visit profile_panels_path

          click_link 'Panel Start'
          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text editor_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text reviewer_grant.name
          end

          click_link 'Panel Start'
          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text reviewer_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text editor_grant.name
          end
        end

        scenario 'reverse sorts on grant name' do
          visit profile_panels_path

          within 'th:nth-child(1)' do
            click_link 'Grant'
          end
          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text editor_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text reviewer_grant.name
          end

          within 'th:nth-child(1)' do
            click_link 'Grant'
          end
          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text reviewer_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text editor_grant.name
          end
        end

        scenario 'reverse sorts on grant review_close_date' do
          visit profile_panels_path

          click_link 'Review Close Date'
          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text editor_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text reviewer_grant.name
          end

          click_link 'Review Close Date'
          within 'tr.panel:nth-child(1)' do
            expect(page).to have_text reviewer_grant.name
          end
          within 'tr.panel:nth-child(2)' do
            expect(page).to have_text editor_grant.name
          end
        end
      end

      context '#search' do
        before(:each) do
          login_user user
          visit profile_panels_path
        end

        scenario 'limits results by search' do
          fill_in 'q_name_cont', with: 'AAA'
          click_button 'Search'

          expect(page).to have_link editor_grant.name, href: grant_panel_path(editor_grant)
          expect(page).not_to have_content reviewer_grant.name
        end

        scenario 'shows not found for empty search' do
          fill_in 'q_name_cont', with: 'TTT'
          click_button 'Search'
          expect(page).not_to have_content 'You have no scheduled Review Panels at this time.'
          expect(page).to have_content 'No panels found'
        end
      end
    end
  end
end

