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
end
