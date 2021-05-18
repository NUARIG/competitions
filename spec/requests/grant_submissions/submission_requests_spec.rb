require 'rails_helper'

RSpec.describe 'grant_submission requests', type: :request do
  let(:grant)        { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:grant_editor) { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer) { grant.grant_permissions.role_viewer.first.user }
  let(:submission)   { grant.submissions.first }

  context '#show' do
    before(:each) do
      sign_in(submission.applicants.first)
    end

    context 'submitted' do
      before(:each) do
        submission.update(state: 'submitted')
      end

      context 'kept' do
        it 'sucessfully renders' do
          get grant_submission_path(grant, submission)

          expect(response).to have_http_status(:success)
        end
      end

      context 'discarded' do
        it 'renders 404', with_errors_rendered: true do
          grant.discard
          get grant_submission_path(grant, submission)

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'draft' do
      before(:each) do
        submission.update(state: 'draft')
      end

      context 'kept' do
        it 'sucessfully renders' do
          get grant_submission_path(grant, submission)

          expect(response).to have_http_status(:success)
        end
      end

      context 'discarded', with_errors_rendered: true do
        it 'renders 404' do
          grant.discard
          get grant_submission_path(grant, submission)

          expect(response).to have_http_status(404)
        end
      end
    end
  end
end
