require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantSubmission::Submission Reviews', type: :system do
  let(:grant)         { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:grant_admin)   { grant.grant_permissions.role_admin.first.user }
  let(:grant_editor)  { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer)  { grant.grant_permissions.role_viewer.first.user }
  let(:submission)    { grant.submissions.first }
  let(:reviewer)      { grant.reviewers.first }
  let(:review)        { create(:review, submission: submission,
                                        assigner: grant_admin,
                                        reviewer: reviewer) }
  let(:new_grant_reviewer) { create(:grant_reviewer, grant: grant) }

  def random_score
    rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE)
  end

  def criterion_id_selector(criterion)
    criterion.name.parameterize(separator: '_')
  end

  describe '#index', js: true do
    before(:each) do
      @grant      = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @admin      = @grant.grant_permissions.role_admin.first.user
      @submission = @grant.submissions.first
      @reviewer   = @grant.reviewers.first
      @submission_review = create(:review, submission: @submission,
                                           assigner: @admin,
                                           reviewer: @reviewer)
    end

    context 'submission with no reviews' do
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

    context 'submission with reviews' do
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

  describe '#show', js: true do
    context 'grant_admin' do
      scenario 'includes a link to edit the review' do
        login_as grant_admin
        visit grant_submission_review_path(grant, submission, review)

        expect(page).to have_link 'Edit', href: edit_grant_submission_review_path(grant, submission, review)
      end
    end

    context 'grant_editor' do
      scenario 'includes a link to edit the review' do
        login_as grant_editor
        visit grant_submission_review_path(grant, submission, review)

        expect(page).to have_link 'Edit', href: edit_grant_submission_review_path(grant, submission, review)
      end
    end

    context 'grant_viewer' do
      scenario 'does not include link to edit the review' do
        login_as grant_viewer
        visit grant_submission_review_path(grant, submission, review)

        expect(page).not_to have_link 'Edit', href: edit_grant_submission_review_path(grant, submission, review)
      end
    end
  end

  describe '#edit', js: true do
    context 'frontend' do
      scenario 'displays appropriate criteria comment field' do
        grant.criteria.first.update_attribute(:show_comment_field, true)

        login_as review.reviewer
        visit edit_grant_submission_review_path(grant, submission, review)

        expect(page).to have_selector("##{criterion_id_selector(grant.criteria.first)}-comment")
        expect(page).not_to have_selector("##{criterion_id_selector(grant.criteria.last)}-comment")
      end
    end
  end

  describe '#update', js: true do
    context 'success' do
      context 'grant_admin' do
        scenario 'may edit the review' do
          login_as grant_admin
          visit edit_grant_submission_review_path(grant, submission, review)
          expect(review.is_complete?).to be false
          grant.criteria.each do |criterion|
            find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
          end
          find("label[for='overall-#{random_score}']").click
          click_button 'Submit Your Review'
          expect(page).to have_text 'Review was successfully updated.'
          expect(review.reload.is_complete?).to be true
        end
      end
    end

    context 'reviewer' do
      context 'foundation form abide feedback' do
        scenario 'provides feedback when a required criterion score is not scored' do
          login_as reviewer
          visit edit_grant_submission_review_path(grant, submission, review)
          click_button 'Submit Your Review'
          expect(page).not_to have_text 'Review was successfully updated.'
          grant.criteria.each do |criterion|
            expect(page).to have_text "#{criterion.name} Score is required"
          end
          expect(review.reload.is_complete?).to be false
        end

        scenario 'provides feedback when overall impact score is not scored' do
          login_as reviewer
          visit edit_grant_submission_review_path(grant, submission, review)
          grant.criteria.each do |criterion|
            find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
          end
          click_button 'Submit Your Review'
          expect(page).not_to have_text 'Review was successfully updated.'
          expect(page).to have_text 'Overall Impact Score is required'
          expect(review.reload.is_complete?).to be false
        end
      end
    end

    context 'failure' do
      let(:scored_review) { create(:scored_review_with_scored_mandatory_criteria_review, submission: submission,
                                                                                         assigner: grant_admin,
                                                                                         reviewer: new_grant_reviewer.reviewer)}

      before(:each) do
        grant.update_attribute(:max_reviewers_per_submission, 2)
        login_as scored_review.reviewer
      end

      scenario 'displays errors if overall impact score is not scored' do
        visit edit_grant_submission_review_path(grant, submission, scored_review)
        allow_any_instance_of(Review).to receive(:overall_impact_score).and_return(nil)

        click_button 'Submit Your Review'
        expect(page).to have_text 'Please review the following error'
      end
    end
  end

  describe '#create', js: true do
    before(:each) do
      grant.update_attribute(:max_reviewers_per_submission, 2)
      applicant           = submission.applicant
    end

    context 'success' do
      before(:each) do
        review
        new_grant_reviewer.reviewer

        login_as grant_admin
        visit grant_reviewers_path(grant)
      end

      scenario 'creates a review' do
        submission_to_assign = find_by_id("submission_#{submission.id}")
        unassigned_reviewer  = find("#reviews_#{new_grant_reviewer.reviewer.id} ul.review_list")

        expect do
          submission_to_assign.drag_to unassigned_reviewer
          wait_for_ajax
        end.to change{grant.reviews.count}.by 1

        expect(page).to have_text "Notification email was sent to #{full_name(new_grant_reviewer.reviewer)}"
      end
    end

    context 'failure' do
      let(:applicant_reviewer) { create(:grant_reviewer, grant: grant,
                                                         reviewer: submission.applicant)}

      before(:each) do
        review
        applicant_reviewer
        login_as grant_admin

        visit grant_reviewers_path(grant)
      end

      scenario 'does not add review when reviewer is applicant' do
        submission_to_assign = find_by_id("submission_#{submission.id}")
        applicant_reviews    = find("#reviews_#{applicant_reviewer.reviewer.id} ul.review_list")

        expect do
          submission_to_assign.drag_to applicant_reviews
          wait_for_ajax
        end.not_to change{grant.reviews.count}

        expect(page).to have_text 'Reviewer may not review their own submission.'
      end

      scenario 'does not add review when reviewer has been assigned' do
        submission_to_assign = find_by_id("submission_#{submission.id}")
        reviewer_reviews    = find("#reviews_#{reviewer.id} ul.review_list")

        expect do
          submission_to_assign.drag_to reviewer_reviews
          wait_for_ajax
        end.not_to change{grant.reviews.count}

        expect(page).to have_text 'Reviewer has already been assigned this submission.'
      end
    end
  end
end
