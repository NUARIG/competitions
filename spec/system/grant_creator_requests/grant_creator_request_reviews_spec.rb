require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantCreatorRequests', type: :system, js: true do
  let(:system_admin)     { create(:system_admin_user) }
  let(:requester)        { create(:user)}
  let(:open_request)     { create(:grant_creator_request, requester: requester) }
  let(:approved_request) { create(:reviewed_approved_grant_creator_request) }
  let(:rejected_request) { create(:reviewed_rejected_grant_creator_request) }
  let(:user)             { create(:user) }

  describe '#show' do
    context 'system_administrator' do
      before(:each) do
        login_as system_admin
      end

      it 'shows the request' do
        visit grant_creator_request_review_path(open_request)

        expect(page).to have_field('First Name', disabled: true, with: requester.first_name)
        expect(page).to have_field('Last Name', disabled: true, with: requester.last_name)
        expect(page).to have_field('Email', disabled: true, with: requester.email)
        expect(page).to have_field('How Do You Plan to Use Competitions?', disabled: true, with: open_request.request_comment)
        expect(page).to have_content 'Pending'
      end
    end
  end

  describe '#edit' do
    context 'system_administrator' do
      before(:each) do
        login_as system_admin
      end

      it 'can approve the request' do
        visit grant_creator_request_review_path(open_request)
        expect(open_request.status_approved?).to be false

        select('Approved', from: 'grant_creator_request[status]')
        click_button 'Review This Access Request'

        expect(open_request.reload.status_approved?).to be true
      end
    end
  end
end
