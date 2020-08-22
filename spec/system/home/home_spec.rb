# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Home', type: :system do
  describe 'Index', js: true do
    before(:each) do
      @open_grant         = create(:grant_with_users)
      @closed_grant       = create(:published_closed_grant)
      @completed_grant    = create(:completed_grant)
      @draft_grant        = create(:draft_open_grant)
      @discarded_grant    = create(:grant_with_users, discarded_at: 1.hour.ago)
      @user               = create(:saml_user)
      @admin_user         = @open_grant.administrators.first
      visit root_path
    end

    describe 'header links' do
      context 'anonymous user' do
        scenario 'displays login link' do
          expect(page).to have_link 'Login'
        end

        scenario 'displays help log in links' do
          expect(page).to have_link 'Help'
          page.find('#help').hover
          expect(page).to have_link 'Logging In'
        end
      end

      context 'logged in user' do
        scenario 'displays user name and profile link' do
          login_user(@user)
          visit root_path
          expect(page).to have_link full_name(@user), href: '#'
          page.find('#logged-in').hover
          expect(page).to have_link 'Edit Your Profile'
        end
      end

      scenario 'does not display help log in link' do
        login_user(@user)
        visit root_path
        expect(page).to have_link 'Help'
        page.find('#help').hover
        expect(page).not_to have_link 'Logging In'
      end
    end

    describe 'grant display logic' do
      scenario 'does not require a login' do
        expect(page).not_to have_content 'You are not authorized to perform this action.'
      end

      scenario 'displays a published grant' do
        expect(page).to have_content @open_grant.name
      end

      scenario 'does not display a closed grant' do
        expect(page).not_to have_content @closed_grant.name
      end

      scenario 'does not display a completed grant' do
        expect(page).not_to have_content @completed_grant.name
      end

      scenario 'does not display a draft grant' do
        expect(page).not_to have_content @draft_grant.name
      end

      scenario 'does not display a soft_deleted grant' do
        expect(page).not_to have_content @discarded_grant.name
      end
    end

    describe 'edit grant link logic' do
      before(:each) do
        @second_open_grant = create(:grant_with_users)
        login_user(@admin_user)
        visit root_path
      end

      scenario 'it does not display edit grant link when user has no permission' do
        expect(page).to have_link 'Edit', href: edit_grant_path(@open_grant)
        expect(page).not_to have_link 'Edit', href: edit_grant_path(@second_open_grant)
      end
    end
  end
end
