require 'rails_helper'

RSpec.describe 'GrantReviews', type: :system, js: true do
  let(:grant)  { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:admin)  { grant.grant_permissions.role_admin.first.user }
  let(:editor) { grant.grant_permissions.role_editor.first.user }
  let(:viewer) { grant.grant_permissions.role_viewer.first.user }

  let!(:review) { create(:incomplete_review, grant: grant,
                                             submission: grant.submissions.first,
                                             reviewer: grant.reviewers.first,
                                             assigner: admin) }

  context '#index' do
    context 'admin' do
      before(:each) do
        login_as(admin)
        visit grant_reviews_path(grant)
      end

      scenario 'displays link to add or assign reviewers' do
        expect(page).to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(grant)
      end

      context 'incomplete reviews' do
        scenario 'displays link to remind reviewers' do
          expect(page).to have_link href: reminders_grant_reviews_path(grant)
        end
      end
    end

    context 'editor' do
      before(:each) do
        login_as(editor)
        visit grant_reviews_path(grant)
      end

      scenario 'displays link to add or assign reviewers' do
        expect(page).to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(grant)
      end

      context 'incomplete reviews' do
        scenario 'displays link to remind reviewers' do
          expect(page).to have_link href: reminders_grant_reviews_path(grant)
        end
      end
    end

    context 'viewer' do
      before(:each) do
        login_as(viewer)
        visit grant_reviews_path(grant)
      end

      scenario 'does not display link to add or assign reviewers' do
        expect(page).not_to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(grant)
      end

      scenario 'does not display link to remind reviewers' do
        expect(page).not_to have_link href: reminders_grant_reviews_path(grant)
      end
    end
  end
end
