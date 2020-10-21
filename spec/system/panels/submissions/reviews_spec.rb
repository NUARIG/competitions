# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Panel Submission Reviews', type: :system, js: true do
  let!(:grant)      { create(:grant_with_users) }
  let!(:submission) { create(:reviewed_submission, grant: grant) }
  let(:admin)       { grant.admins.first }
  let(:reviewer1)   { submission.reviews.first.reviewer }
  let(:applicant)   { submission.applicant }
  let(:review1)     { submission.review.first}

  let!(:reviewer2)  { create(:grant_reviewer, grant: grant).reviewer }
  let!(:review2)    { create(:scored_review_with_scored_mandatory_criteria_review,  submission: submission,
                                                                                    reviewer: reviewer2,
                                                                                    assigner: admin) }
  let!(:reviewer3)  { create(:grant_reviewer, grant: grant).reviewer }
  let!(:review3)    { create(:incomplete_review,  submission: submission,
                                                  reviewer: reviewer3,
                                                  assigner: admin) }

  describe 'Index' do
    context 'admins' do
      before(:each) do
        submission.save
        login_user grant.admins.first
        visit grant_panel_submission_reviews_path(grant, submission)
      end

      scenario 'includes submission information' do
        expect(page).to have_content submission.title
        expect(page).to have_content submission.average_overall_impact_score
        expect(page).to have_content submission.composite_score
        expect(page).to have_content full_name(applicant)
      end

      scenario 'includes complete review information' do
        expect(page).to have_content full_name(reviewer1)
        expect(page).to have_content full_name(reviewer2)
      end

      scenario 'does not include incomplete review' do
        expect(page).not_to have_content full_name(reviewer3)
      end
    end
  end
end
