require 'rails_helper'

RSpec.describe 'grant reviews requests', type: :request do
  let(:grant)        { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:grant_editor) { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer) { grant.grant_permissions.role_viewer.first.user }
  let(:submission)   { grant.submissions.first }
  let(:reviewer)     { grant.reviewers.first }
  let(:review)       { create(:review, submission: submission,
                                       assigner: grant.grant_permissions.role_admin.first.user,
                                       reviewer: reviewer) }
  let(:invalid_user) { create(:user) }

  context '#index' do
    before(:each) do
      review.touch
      sign_in(grant_editor)
    end

    context 'xlsx formats' do
      it 'renders a xlsx' do
        get grant_reviews_path(grant).to_s + '.xlsx'
        expect(response.content_type).to include 'openxml'
      end

      it 'renders xlsx for long name Grant' do
        grant.update_attribute(:name, Faker::Lorem.characters(number: 35))
        get grant_reviews_path(grant).to_s + '.xlsx'
        expect(response.content_type).to include 'openxml'
      end
    end
  end
end
