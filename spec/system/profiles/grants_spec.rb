require 'rails_helper'
include UsersHelper

RSpec.describe 'Profile Grants', type: :system, js: true do
  let(:unaffiliated_grant)        { create(:grant) }
  let(:grant1)                    { create(:open_grant_with_users_and_form_and_submission_and_reviewer, name: "First #{Faker::Lorem.sentence(word_count: 3)}") }
  let(:grant2)                    { create(:draft_grant) }
  let(:grant3)                    { create(:published_grant) }
  let(:grant4)                    { create(:draft_grant)}
  let!(:grant1_permission)         { grant1.grant_permissions.role_admin.first }
  let!(:grant2_viewer_permission)  { create(:viewer_grant_permission,  grant: grant2,
                                                                      user: grant1.admins.first) }
  let!(:grant3_editor_permission)  { create(:editor_grant_permission,  grant: grant3,
                                                                      user: grant1.admins.first) }
  let!(:grant4_admin_permission)   { create(:admin_grant_permission,   grant: grant4,
                                                                      user: grant1.admins.first) }

  let(:grant_admin)               { grant1.admins.first }
  let(:user)                      { create(:saml_user) }

  context 'header text' do
    context 'submitter' do
      scenario 'displays MyGrants link in the header' do
        login_as grant_admin

        visit root_path
        expect(page).to have_link('MyGrants', href: profile_grants_path)
      end
    end

    context 'user with no submissions' do
      scenario 'does not display MyGrants link in the header' do
        login_as user

        visit root_path
        expect(page).not_to have_link('MyGrants', href: profile_grants_path)
      end
    end
  end

  context '#index' do
    context 'grant_admin' do
      before(:each) do
        login_user grant_admin
        visit profile_grants_path
      end

      scenario 'it includes links to all the user\'s grants' do
        expect(page).to have_link(grant1.name, href: grant_path(grant1))
        expect(page).to have_link(grant2.name, href: grant_path(grant2))
        expect(page).to have_link(grant3.name, href: grant_path(grant3))
        expect(page).to have_link(grant4.name, href: grant_path(grant4))
        expect(page).not_to have_link(unaffiliated_grant.name, href: grant_path(unaffiliated_grant))
      end

      context 'manage links' do
        scenario 'are included' do
          [grant1, grant2, grant3, grant4].each do |grant|
            expect(page).to have_selector "td.manage[data-grant-id='#{grant.id}']"
          end
        end

        context 'admin role' do
          scenario 'includes proper links' do
            find("td.manage[data-grant-id='#{grant1.id}']").hover
            expect(page).to have_link 'Edit',         href: edit_grant_path(grant1)
            expect(page).to have_link 'Submissions',  href: grant_submissions_path(grant1)
            expect(page).to have_link 'Reviews',      href: grant_reviews_path(grant1)
            expect(page).to have_link 'Duplicate',    href: new_grant_duplicate_path(grant1)
            expect(page).not_to have_link 'Delete',   href: grant_path(grant1)

            find("td.manage[data-grant-id='#{grant4.id}']").hover
            expect(page).to have_link 'Delete', href: grant_path(grant4)
          end
        end

        context 'editor role' do
          scenario 'includes proper links' do
            find("td.manage[data-grant-id='#{grant3.id}']").hover
            expect(page).to have_link 'Edit',           href: edit_grant_path(grant3)
            expect(page).to have_link 'Submissions',    href: grant_submissions_path(grant3)
            expect(page).to have_link 'Reviews',        href: grant_reviews_path(grant3)
            expect(page).not_to have_link 'Duplicate',  href: new_grant_duplicate_path(grant2)
            expect(page).not_to have_link 'Delete',     href: grant_path(grant2)
          end
        end

        context 'viewer role' do
          scenario 'includes proper links' do
            find("td.manage[data-grant-id='#{grant2.id}']").hover
            expect(page).to have_link 'Edit',           href: edit_grant_path(grant2)
            expect(page).to have_link 'Submissions',    href: grant_submissions_path(grant2)
            expect(page).to have_link 'Reviews',        href: grant_reviews_path(grant2)
            expect(page).not_to have_link 'Duplicate',  href: new_grant_duplicate_path(grant2)
            expect(page).not_to have_link 'Delete',     href: grant_path(grant2)
          end
        end
      end

      scenario 'it can be filtered on grant name' do
        find_field('Search Grant Name', with: '').set ('First')
        click_button 'Search'

        expect(page).to have_link(grant1.name, href: grant_path(grant1))
        expect(page).not_to have_link(grant2.name, href: grant_path(grant2))
        expect(page).not_to have_link(grant3.name, href: grant_path(grant3))
      end
    end
  end
end
