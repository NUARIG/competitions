require 'rails_helper'

RSpec.describe 'PanelsRedirect', type: :system, js: true do
  let(:grant)       { create(:published_closed_grant_with_users) }
  let(:panel)       { grant.panel }
  let(:submitted_review) do
    create(:submitted_scored_review_with_scored_mandatory_criteria_review,
           submission: grant.submissions.first,
           assigner: grant.admins.first,
           reviewer: grant.reviewers.first)
  end
  let(:submission) { submitted_review.submission }
  let(:submitter) { submitted_review.submitter }
  let(:user) { create(:saml_user) }

  describe 'Redirect' do
    context 'panel page' do
      scenario 'submitter is redirected' do
        login_user submitter
        visit grant_panel_path(grant)

        expect(current_path).to eql(root_path)
      end
    end

    context 'submission page' do
      scenario 'unconnected user is redirected' do
        login_user user
        visit grant_panel_submission_path(grant, submission)

        expect(current_path).to eql(root_path)
      end
    end

    context 'submission reviews page' do
      scenario 'unconnected user is redirected' do
        login_user user
        visit grant_panel_submission_reviews_path(grant, submission)

        expect(current_path).to eql(root_path)
      end
    end
  end
end
