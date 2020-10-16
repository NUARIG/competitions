require 'rails_helper'

RSpec.describe 'submissions requests', type: :request do
  let(:grant) { create(:published_closed_grant_with_users) }

  describe 'index', js: true do
    scenario 'redirects to panel home' do
      login_user(grant.admins.first)
      get grant_panel_submissions_path(grant)

      expect(response).to have_http_status :redirect
      expect(response).to redirect_to grant_panel_path(grant)
    end
  end
end
