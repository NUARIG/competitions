require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantCreatorRequests', type: :system, js: true do
  let(:system_admin)     { create(:system_admin_saml_user) }
  let(:open_request)     { create(:grant_creator_request) }
  let(:approved_request) { create(:reviewed_approved_grant_creator_request) }
  let(:rejected_request) { create(:reviewed_rejected_grant_creator_request) }
  let(:user)             { create(:saml_user) }

  describe '#index' do
    it 'only includes the open requests' do
      [open_request, approved_request, rejected_request]
      login_as system_admin
      visit grant_creator_requests_path
      expect(page).to have_content full_name(open_request.requester)
      expect(page).to have_link href: grant_creator_request_review_path(open_request)
      expect(page).not_to have_link href: grant_creator_request_review_path(approved_request)
      expect(page).not_to have_link href: grant_creator_request_review_path(rejected_request)
    end
  end

  describe '#create' do
    before(:each) do
      login_as(user, scope: :saml_user)
      visit new_grant_creator_request_path
    end

    context 'success' do
      it 'accepts a valid request' do
        page.fill_in "How Do You Plan to Use #{COMPETITIONS_CONFIG[:application_name]}?", with: Faker::Lorem.sentence
        click_button 'Request Grant Creation Access'
        expect(page).to have_content 'Your request has been sent. You will be notified after review.'
        expect(current_path).to eq(profile_path)
      end
    end

    context 'failure' do
      it 'rejects an incomplete request' do
        expect do
          click_button 'Request Grant Creation Access'
          expect(page).to have_content 'Comment is required'
        end.to_not change{GrantCreatorRequest.count}
      end
    end
  end

  describe '#update' do
    before(:each) do
      login_as(open_request.requester, scope: :saml_user)
      visit grant_creator_request_path(open_request)
    end

    context 'success' do
      it 'accepts a valid request' do
        page.fill_in "How Do You Plan to Use #{COMPETITIONS_CONFIG[:application_name]}?", with: "Updated #{Faker::Lorem.sentence}"
        click_button 'Re-submit This Grant Creation Access Request'
        expect(page).to have_content 'Your request has been updated. You will be notified after review.'
        expect(current_path).to eq(profile_path)
      end
    end

    context 'failure' do
      it 'rejects an incomplete request' do
        page.fill_in "How Do You Plan to Use #{COMPETITIONS_CONFIG[:application_name]}?", with: ''
        click_button 'Re-submit This Grant Creation Access Request'
        expect(page).to have_content 'Comment is required'
      end
    end
  end
end
