require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantSubmission::Submission Reviews', type: :system do
  describe 'Index', js: true do
    before(:each) do
      @grant      = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @admin      = @grant.editors.first
      @submission = @grant.submissions.first
      @reviewer   = @grant.reviewers.first
      @submission_review = create(:review, submission: @submission,
                                               assigner: @admin,
                                               reviewer: @reviewer)
     end

    context 'No reviews' do
      context 'Admin' do
        before(:each) do
          @submission.reviews.delete_all
          login_as(@admin)
          visit grant_submission_reviews_path(@grant, @submission)
        end

        scenario 'prompts to assign review when there are none' do
          expect(page).to have_text 'There are no reviews for this submission.'
          expect(page).to have_link 'Assign it to a reviewer', href: grant_reviewers_path(@grant)
        end
      end
    end

    context 'With reviews' do
      before(:each) do
        login_as(@admin)
        visit grant_submission_reviews_path(@grant, @submission)
      end

      scenario 'displays table with all criteria' do
        criteria = @grant.criteria.pluck(:name)
        headers = all('th').map {|column| column.text.strip }
        expect(criteria.all? { |criterion| headers.include?(criterion) }).to be true
      end

      scenario 'includes table of assigned reviews' do
        expect(page).to have_text sortable_full_name(@reviewer)
        expect(page).to have_text 'Incomplete'
      end
    end
  end
end
