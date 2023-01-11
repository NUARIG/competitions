require 'rails_helper'
include UsersHelper
include ActionView::RecordIdentifier

RSpec.describe 'Home', type: :system do
  let(:open_grant)        { create(:grant_with_users) }
  let(:closed_grant)      { create(:published_closed_grant) }
  let(:completed_grant)   { create(:completed_grant) }
  let(:draft_grant)       { create(:draft_open_grant) }
  let(:discarded_grant)   { create(:grant_with_users, discarded_at: 1.hour.ago) }
  let(:user)              { create(:saml_user) }
  let(:admin_user)        { open_grant.administrators.first }
  let(:long_name_grant)   { create(:grant_with_users, name: Faker::Lorem.paragraph_by_chars(number: 156))}
  let(:second_open_grant) { create(:grant_with_users) }


  describe 'Index', js: true do
    describe 'header links' do
      context 'anonymous user' do
        before(:each) do
          visit root_path
        end

        scenario 'displays login link' do
          within('header') do
            expect(page).to have_button 'Log In'
          end
        end

        scenario 'displays help log in links' do
          within('header') do
            expect(page).to have_link 'Help'
            page.find('#help').hover
            expect(page).to have_link 'Release Notes'
          end
        end
      end

      context 'logged in user' do
        before(:each) do
          login_as(user, scope: :saml_user)
          visit root_path
        end

        scenario 'displays user name and profile link' do
          within('header') do
            expect(page).to have_link full_name(user), href: '#'
            page.find('#logged-in').hover
            expect(page).to have_link 'Edit Your Profile'
          end
        end

        scenario 'does not display help log in link' do
          within('header') do
            expect(page).to have_link 'Help'
            page.find('#help').hover
            expect(page).not_to have_link 'Logging In'
          end
        end
      end
    end

    describe 'grant display logic' do
      before(:each) do
        open_grant.touch
        closed_grant.touch
        completed_grant.touch
        draft_grant.touch
        discarded_grant.touch

        visit root_path
      end

      scenario 'does not require a login' do
        expect(page).not_to have_content 'You are not authorized to perform this action.'
      end

      scenario 'displays a published grant' do
        within('#public-grants') do
          expect(page).to have_content open_grant.name
        end
      end

      scenario 'does not display a closed grant' do
        within('#public-grants') do
          expect(page).not_to have_content closed_grant.name
        end
      end

      scenario 'does not display a completed grant' do
        within('#public-grants') do
          expect(page).not_to have_content completed_grant.name
        end
      end

      scenario 'does not display a draft grant' do
        within('#public-grants') do
          expect(page).not_to have_content draft_grant.name
        end
      end

      scenario 'does not display a soft_deleted grant' do
        within('#public-grants') do
          expect(page).not_to have_content discarded_grant.name
        end
      end
    end

    describe 'edit grant link logic' do
      before(:each) do
        second_open_grant.touch
        login_as(admin_user, scope: :saml_user)
        visit root_path
      end

      scenario 'it does not display edit grant link when user has no permission' do
        expect(page).to have_link 'Edit', href: edit_grant_path(open_grant)
        expect(page).not_to have_link 'Edit', href: edit_grant_path(second_open_grant)
      end
    end

    describe 'grant name truncation logic' do
      before(:each) do
        long_name_grant.touch
        visit root_path
      end

      scenario 'truncates grant names longer than 150 characters' do
        within("##{dom_id(long_name_grant)}") do
          expect(page).not_to have_content long_name_grant.name
          expect(page).to have_content (long_name_grant.name.first(147) + '...')
        end
      end
    end

      end
    end
  end
end
