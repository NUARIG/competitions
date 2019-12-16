require 'rails_helper'

RSpec.describe 'GrantReviews', type: :system, js: true do
  before(:each) do
    @grant  = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @admin  = @grant.grant_permissions.role_admin.first.user
    @editor = @grant.grant_permissions.role_editor.first.user
    @viewer = @grant.grant_permissions.role_viewer.first.user
  end

  context '#index' do
    context 'admin' do
      scenario 'displays link to add or assign reviewers' do
        login_as(@admin)
        visit grant_reviews_path(@grant)
        expect(page).to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(@grant)
      end
    end

    context 'editor' do
      scenario 'displays link to add or assign reviewers' do
        login_as(@editor)
        visit grant_reviews_path(@grant)
        expect(page).to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(@grant)
      end
    end

    context 'viewer' do
      scenario 'does not display link to add or assign reviewers' do
        login_as(@viewer)
        visit grant_reviews_path(@grant)
        expect(page).not_to have_link 'Add reviewers or assign reviews', href: grant_reviewers_path(@grant)
      end
    end
  end
end
