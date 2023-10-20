# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.describe 'Panel Submission Reviews', type: :system, js: true do
  let!(:grant)      { create(:grant_with_users) }
  let!(:submission) { create(:reviewed_submission, grant: grant) }
  let(:admin)       { grant.admins.first }
  let(:reviewer1)   { submission.reviews.first.reviewer }
  let(:submitter)   { submission.submitter }
  let(:review1)     { submission.review.first}

  let!(:reviewer2)  { create(:grant_reviewer, grant: grant).reviewer }
  let!(:review2)    { create(:submitted_scored_review_with_scored_commented_criteria_review, submission: submission,
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
        expect(page).to have_content full_name(submitter)
      end

      scenario 'includes complete review information' do
        expect(page).to have_content full_name(reviewer1)
        expect(page).to have_content full_name(reviewer2)
      end

      scenario 'does not include incomplete review' do
        expect(page).not_to have_content full_name(reviewer3)
      end

      context 'show_reviewer_comments' do
        scenario 'when false, shows review comments' do
          grant.panel.update(show_review_comments: false)
          visit grant_panel_submission_reviews_path(grant, submission)
          expect(find_by_id('criteria-reviews')).not_to have_content 'Scores and Comments'
          expect(find_by_id('overall-impact-scores')).not_to have_content 'Overall Impact Scores and Comments'
          expect(page).not_to have_text review2.overall_impact_comment
          review2.criteria_reviews.each do |criteria_review|
            expect(page).not_to have_text criteria_review.comment
          end
        end

        scenario 'when true, shows review comments' do
          grant.panel.update(show_review_comments: true)
          visit grant_panel_submission_reviews_path(grant, submission)
          expect(find_by_id('criteria-reviews')).to have_content 'Scores and Comments'
          expect(find_by_id('overall-impact-scores')).to have_content 'Overall Impact Scores and Comments'
          expect(page).to have_text review2.overall_impact_comment
          review2.criteria_reviews.each do |criteria_review|
            expect(page).to have_text criteria_review.comment
          end

        end
      end
    end
  end
end
