# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Login', type: :system do

  describe 'Home page', js: true do
    scenario 'home page login link navigates to login page' do
      visit root_path
      expect(page).to have_link 'Login'
      click_link 'Login'
      expect(current_path).to eq(login_index_path)
    end
  end

  describe 'Login page', js: true do
    before(:each) do
      visit login_index_path
    end

    scenario 'login page has proper text' do
      expect(page).to have_text 'Login using:'
    end

    scenario 'login page has SAML ID login button' do
      expect(page).to have_selector(:link_or_button, "#{COMPETITIONS_CONFIG[:devise][:saml_authenticatable][:idp_entity_name]}")
    end

    scenario 'login page has Registered Account login button' do
      expect(page).to have_selector(:link_or_button, 'Registered Account')
    end
  end
end
