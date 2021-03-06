# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Login', type: :system do

  describe 'Home page', js: true do
    scenario 'home page login link navigates to login page' do
      visit root_path
      expect(page).to have_link 'Log in'
      click_link 'Log in'
      expect(current_path).to eq(login_index_path)
    end
  end

  describe 'Login page', js: true do
    before(:each) do
      visit login_index_path
    end

    scenario 'login page has SAML ID login button' do
      expect(page).to have_selector(:link_or_button, "With #{COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]}")
    end

    scenario 'login page has Registered Account login form' do
      expect(page).to have_selector('#registered_user_uid')
      expect(page).to have_selector('#registered_user_password')
    end
  end

  describe 'deep linking on log in', js: true do
    let(:grant)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:registered_editor)   { create(:registered_user) }
    let(:editor_permission)   { create(:grant_permission, grant: grant, user: registered_editor) }

    context 'log in to grant reviews index' do
      scenario 'it redirects to the deep link on login' do
        editor_permission
        visit grant_reviews_path(grant)
        find(:css, "#registered_user_uid").set(registered_editor.email)
        find(:css, "#registered_user_password").set(registered_editor.password)
        click_button 'Log in'
        expect(page).to have_current_path grant_reviews_path(grant)
      end
    end
  end
end
