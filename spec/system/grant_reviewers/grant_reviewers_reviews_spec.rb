require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantReviewers::Reviews', type: :system do
  describe '#index', js: true do
    let(:grant) { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:grant_admin) { grant.administrators.first }
    let(:reviewer) { grant.reviewers.first }
    let(:submission) { grant.submissions.first }
    let(:review) do
      create(:submitted_scored_review_with_scored_mandatory_criteria_review,
             submission: submission,
             assigner: grant_admin,
             reviewer: reviewer)
    end
    let(:submitter) { grant.submissions.first.submitter }

    before(:each) do
      review.touch
      login_as(grant_admin, scope: :saml_user)
      visit grant_reviewers_path(grant)
    end

    scenario 'it displays assigned submission per reviewer' do
      dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"
      grant.grant_reviewers.first.destroy!
      within('#reviewers') do
        find(dropdown_menu_id).hover
        find_link('View Assigned').click
        pause
      end
      within('#modal') do
        expect(page).to have_content(full_name(submitter))
        expect(page).to have_link('Submitted', href: grant_submission_review_path(grant, submission, review))
      end
    end

    scenario 'it can delete an assigned submission per reviewer' do
      dropdown_menu_id = "#manage_#{dom_id(grant.grant_reviewers.first)}"
      within('#reviewers') do
        find(dropdown_menu_id).hover
        find_link('View Assigned').click
        pause
      end
      within('#modal') do
        accept_alert do
          click_button 'Unassign'
        end
      end
      pause
      expect(page).to have_text("Review unassigned. A notifcation email was sent to #{full_name(reviewer)}.")
    end
  end
end
