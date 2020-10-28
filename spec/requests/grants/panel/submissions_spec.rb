require 'rails_helper'

RSpec.describe 'submissions requests', type: :request do
  let!(:grant)      { create(:closed_grant_with_users_and_form_and_submission_and_reviewer) }
  let!(:submission) { create(:reviewed_submission,  grant: grant,
                                                    user_updated_at: grant.submission_close_date - 1.hour) }

  describe 'index', js: true do
    scenario 'redirects to panel home' do
      login_user(grant.admins.first)
      get grant_panel_submissions_path(grant)

      expect(response).to have_http_status :redirect
      expect(response).to redirect_to grant_panel_path(grant)
    end
  end

  describe 'show' do
    context 'closed panel' do
      scenario 'user with no permissions redirects to root' do
        login_user create(:user)
        get grant_panel_submission_path(grant, submission)

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to root_path
      end

      scenario 'reviewer redirects to panel' do
        login_user submission.reviewers.first
        get grant_panel_submission_path(grant, submission)

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to grant_panel_path(grant)
      end

      scenario 'admin does not redirects' do
        login_user grant.admins.first
        get grant_panel_submission_path(grant, submission)

        expect(response).not_to have_http_status :redirect
      end
    end

    context 'open panel' do
      before(:each) do
        grant.panel.update(start_datetime: 1.hour.ago, end_datetime: 1.hour.from_now)
      end

      scenario 'user with no permissions redirects to root' do
        login_user create(:user)
        get grant_panel_submission_path(grant, submission)

        expect(response).to have_http_status :redirect
        expect(response).to redirect_to root_path
      end

      scenario 'reviewer does not redirect' do
        login_user submission.reviewers.first
        get grant_panel_submission_path(grant, submission)

        expect(response).not_to have_http_status :redirect
      end

      scenario 'admin does not redirect' do
        login_user grant.admins.first
        get grant_panel_submission_path(grant, submission)

        expect(response).not_to have_http_status :redirect
      end
    end
  end
end
