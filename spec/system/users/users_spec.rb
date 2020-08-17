# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Users', type: :system, js: true  do
  describe '#authenticate_user!' do
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