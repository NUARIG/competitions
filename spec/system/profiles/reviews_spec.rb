require 'rails_helper'
include UsersHelper

RSpec.describe 'Profile Reviews', type: :system, js: true do
  let(:grant1)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer, name: "First #{Faker::Lorem.sentence(word_count: 3)}") }
  let(:reviewer)           { grant1.reviewers.first }
  let(:grant1_review)      { create(:review, submission: grant1.submissions.first,
                                             assigner: grant1.grant_permissions.role_admin.first.user,
                                             reviewer: reviewer) }
  let(:grant2)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer, name: "Second #{Faker::Lorem.sentence(word_count: 3)}") }
  let(:grant2_reviewer)    { create(:grant_reviewer, grant: grant2,
                                                     reviewer: reviewer) }
  let(:grant2_review)      { create(:scored_review_with_scored_mandatory_criteria_review, submission: grant2.submissions.first,
                                                                                          assigner: grant2.grant_permissions.role_admin.first.user,
                                                                                          reviewer: grant2_reviewer.reviewer)}
  let(:draft_grant)             { create(:draft_open_grant_with_users_and_form_and_submission_and_reviewer, name: "Second #{Faker::Lorem.sentence(word_count: 3)}") }
  let(:draft_grant_reviewer)    { create(:grant_reviewer, grant: draft_grant,
                                                     reviewer: reviewer) }
  let(:draft_grant_review)      { create(:scored_review_with_scored_mandatory_criteria_review, submission: draft_grant.submissions.first,
                                                                                          assigner: draft_grant.grant_permissions.role_admin.first.user,
                                                                                          reviewer: draft_grant_reviewer.reviewer)}
  let(:registered_user)         { create(:registered_user) }
  let(:saml_user)               { create(:saml_user) }

  describe 'header text' do
    context 'reviewer' do
      scenario 'it displays link in the header' do
        grant1_review
        login_user(reviewer)
        visit root_path
        expect(page).to have_link('MyReviews', href: profile_reviews_path)
      end
    end

    context 'saml_user' do
      context 'non-reviewer' do
        scenario 'it does not display link in header' do
          login_user(saml_user)
          visit root_path
          expect(page).not_to have_link('MyReviews', href: profile_reviews_path)
        end
      end
    end

    context 'registered_user' do
      context 'non-reviewer' do
        scenario 'it does not display link in header' do
          login_user(registered_user)
          visit root_path
          expect(page).not_to have_link('MyReviews', href: profile_reviews_path)
        end
      end
    end
  end

  describe '#index' do
    before(:each) do
      grant1_review
      grant2_review
      draft_grant_review

      login_user(reviewer)
      visit profile_reviews_path
    end

    context '#index' do

      scenario 'it includes links to assigned reviews' do
        expect(page).to have_text(grant1.name)
        expect(page).to have_text(grant2.name)
        expect(page).to have_text(draft_grant.name)
        expect(page).to have_link('Incomplete', href: grant_submission_review_path(grant1, grant1.submissions.first, grant1_review))
        expect(page).to have_link('Completed', href: grant_submission_review_path(grant2, grant2.submissions.first, grant2_review))
        expect(page).not_to have_link('Completed', href: grant_submission_review_path(draft_grant, draft_grant.submissions.first, draft_grant_review))
      end

      scenario 'it can be filtered on grant name' do
        find_field('Search by Grant Name', with: '').set('First')
        click_button 'Search'

        expect(page).to have_text grant1.name
        expect(page).to have_link(href: grant_submission_review_path(grant1, grant1.submissions.first, grant1_review))
        expect(page).not_to have_text grant2.name
        expect(page).not_to have_link(href: grant_submission_review_path(grant2, grant2.submissions.first, grant2_review))
      end

      scenario 'it does not include reviews for discarded grants' do
        grant1.discard
        visit profile_reviews_path

        expect(page).not_to have_text(grant1.name)
        expect(page).not_to have_link('Incomplete', href: grant_submission_review_path(grant1, grant1.submissions.first, grant1_review))
        expect(page).to have_text(grant2.name)
        expect(page).to have_link('Completed', href: grant_submission_review_path(grant2, grant2.submissions.first, grant2_review))
      end
    end
  end
end
