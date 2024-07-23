require 'rails_helper'
include UsersHelper
include ActionView::Helpers::TextHelper
include GrantSubmissions::SubmissionsHelper

RSpec.describe 'GrantSubmission::Submission Reviews', type: :system do
  let(:grant) do
    create(:open_grant_with_users_and_form_and_submission_and_reviewer,
           :with_unrequired_commentable_criterion)
  end
  let(:grant_admin)           { grant.grant_permissions.role_admin.first.user }
  let(:grant_editor)          { grant.grant_permissions.role_editor.first.user }
  let(:grant_viewer)          { grant.grant_permissions.role_viewer.first.user }
  let(:submission)            { grant.submissions.first }
  let(:reviewer)              { grant.reviewers.first }
  let(:review)                do
    create(:review,
           submission: submission,
           assigner: grant_admin,
           reviewer: reviewer)
  end
  let(:new_grant_reviewer)    { create(:grant_reviewer, grant: grant) }
  let(:applicant)             { create(:saml_user) }
  let(:submission_applicant)  do
    create(:grant_submission_submission_applicant,
           submission: submission,
           applicant: applicant)
  end

  let(:reviewer2)             { create(:grant_reviewer, grant: grant).reviewer }
  let(:reviewer3)             { create(:grant_reviewer, grant: grant).reviewer }

  let(:assigned_review)       do
    create(:review,
           submission: submission,
           assigner: grant_admin,
           reviewer: reviewer)
  end
  let(:draft_scored_review) do
    create(:draft_scored_review_with_scored_mandatory_criteria_review,
           submission: submission,
           assigner: grant_admin,
           reviewer: reviewer2)
  end
  let(:submitted_scored_review) do
    create(:submitted_scored_review_with_scored_mandatory_criteria_review,
           submission: submission,
           assigner: grant_admin,
           reviewer: reviewer3)
  end
  let(:unscored_criterion_id) { submitted_scored_review.criteria_reviews.last.criterion.id }

  def random_score
    rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE)
  end

  def criterion_id_selector(criterion)
    criterion.name.parameterize(separator: '_')
  end

  describe '#index', js: true do
    before(:each) do
      assigned_review.touch
    end

    context 'submission with no reviews' do
      context 'Admin' do
        before(:each) do
          submission.reviews.destroy_all
          login_as(grant_admin, scope: :saml_user)

          visit grant_submission_reviews_path(grant, submission)
        end

        scenario 'prompts to assign review when there are none' do
          expect(page).to have_text 'There are no reviews for this submission.'
          expect(page).to have_link 'Assign it to a reviewer', href: grant_reviewers_path(grant)
        end
      end
    end

    context 'submission with reviews' do
      before(:each) do
        login_as(grant_admin, scope: :saml_user)
      end

      context 'assigned review' do
        before(:each) do
          visit grant_submission_reviews_path(grant, submission)
        end

        scenario 'displays table with all criteria' do
          criteria = grant.criteria.pluck(:name)
          headers  = all('th').map { |column| column.text.strip }
          expect(criteria.all? { |criterion| headers.include?(criterion) }).to be true
        end

        scenario 'includes table of assigned reviews' do
          expect(page).to have_text sortable_full_name(reviewer)
          expect(page).to have_text 'Assigned'
        end

        scenario 'does not include score and comment summary' do
          expect(page).not_to have_text 'Scores and Comments'
          expect(page).not_to have_text 'Overall Impact Scores and Comments'
        end
      end

      context 'draft review' do
        before(:each) do
          draft_scored_review.touch
          visit grant_submission_reviews_path(grant, submission)
        end

        scenario 'includes table of draft and assigned reviews' do
          within "#review-#{assigned_review.id}" do
            expect(page).to have_text sortable_full_name(reviewer)
            expect(page).to have_text 'Assigned'
          end
          within "#review-#{draft_scored_review.id}" do
            expect(page).to have_text sortable_full_name(reviewer2)
            expect(page).to have_text 'Draft'
          end
        end

        scenario 'does not include score and comment summary' do
          expect(page).not_to have_text 'Scores and Comments'
          expect(page).not_to have_text 'Overall Impact Scores and Comments'
        end
      end

      context 'completed review' do
        before(:each) do
          grant.criteria.first.update(show_comment_field: true, is_mandatory: false)

          # last criterion is not required b/c of additional trait
          submitted_scored_review.criteria_reviews.last.update(score: nil, comment: 'Commented criterion.')
          submitted_scored_review.criteria_reviews.last

          submitted_scored_review.criteria_reviews.last.criterion
          visit grant_submission_reviews_path(grant, submission)
        end

        scenario 'includes scores and comments' do
          expect(page).to have_text 'Scores and Comments'
          expect(page).to have_text 'Overall Impact Scores and Comments'
        end

        scenario 'displays NS for unscored criteria' do
          expect(find_by_id("criterion-#{unscored_criterion_id}-score")).to have_text 'NS'
        end

        scenario 'displays comment when commented' do
          expect(find_by_id("criterion-#{unscored_criterion_id}-comment")).to have_text 'Commented criterion.'
        end

        scenario 'does not have comment selector if no comment' do
          uncommented_criterion_id = submitted_scored_review.criteria_reviews.first.criterion.id
          expect(page).not_to have_selector "criterion-#{uncommented_criterion_id}-comment"
        end
      end
    end
  end

  describe '#show', js: true do
    context 'grant_admin' do
      scenario 'includes a link to edit the review' do
        login_as(grant_admin, scope: :saml_user)
        visit grant_submission_review_path(grant, submission, review)

        expect(page).to have_link 'Edit', href: edit_grant_submission_review_path(grant, submission, review)
      end
    end

    context 'grant_editor' do
      scenario 'includes a link to edit the review' do
        login_as(grant_editor, scope: :saml_user)
        visit grant_submission_review_path(grant, submission, review)
        expect(page).to have_link 'Edit', href: edit_grant_submission_review_path(grant, submission, review)
      end
    end

    context 'grant_viewer' do
      scenario 'does not include link to edit the review' do
        login_as(grant_viewer, scope: :saml_user)
        visit grant_submission_review_path(grant, submission, review)

        expect(page).not_to have_link 'Edit', href: edit_grant_submission_review_path(grant, submission, review)
      end
    end
  end

  describe '#edit', js: true do
    context 'frontend' do
      scenario 'displays appropriate criteria comment field' do
        grant.criteria.first.update(show_comment_field: true)

        login_as(review.reviewer, scope: :saml_user)

        visit edit_grant_submission_review_path(grant, submission, review)
        expect(page).to have_selector("##{criterion_id_selector(grant.criteria.first)}-comment")
        expect(page).not_to have_selector("##{criterion_id_selector(grant.criteria.second)}-comment")
      end

      context 'closed review period' do
        context 'reviewer' do
          before(:each) do
            login_as review.reviewer
          end

          scenario 'displays warning message' do
            allow_any_instance_of(Review).to receive(:review_period_closed?).and_return(true)
            visit edit_grant_submission_review_path(grant, submission, review)
            expect(page).to have_content('Review period is closed')
          end

          scenario 'disables each criteria and overall impact review button' do
            allow_any_instance_of(Review).to receive(:review_period_closed?).and_return(true)
            visit edit_grant_submission_review_path(grant, submission, review)

            Capybara.ignore_hidden_elements = false
            grant.criteria.each do |criterion|
              (1..9).each do |i|
                expect(page.find_field("#{criterion_id_selector(criterion)}-#{i}", disabled: true)).not_to be nil
              end
            end
            (1..9).each do |i|
              expect(page.find_field("overall-#{i}", disabled: true)).not_to be nil
            end
            Capybara.ignore_hidden_elements = true
          end

          scenario 'disables the submit button' do
            allow_any_instance_of(Review).to receive(:review_period_closed?).and_return(true)
            visit edit_grant_submission_review_path(grant, submission, review)
            expect(page).to have_button('Submit Your Review', disabled: true)
          end
        end
      end
    end
  end

  describe '#update', js: true do
    context 'success' do
      context 'grant_admin' do
        before(:each) do
          login_as(grant_admin, scope: :saml_user)
          visit edit_grant_submission_review_path(grant, submission, review)
        end

        scenario 'may edit the review' do
          expect(review.is_complete?).to be false
          grant.criteria.each do |criterion|
            find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
          end
          find("label[for='overall-#{random_score}']").click
          click_button 'Submit Your Review'
          expect(page).to have_text 'Review was successfully updated.'
          expect(review.reload.is_complete?).to be true
          expect(review.submitted?).to be true
        end

        scenario 'redirects to Grant Submissions path' do
          grant.criteria.each do |criterion|
            find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
          end
          find("label[for='overall-#{random_score}']").click
          click_button 'Submit Your Review'
          expect(page).to have_text 'Review was successfully updated.'
          expect(page.current_path).to eql(grant_reviews_path(grant))
        end
      end
    end

    context 'reviewer' do
      before(:each) do
        login_as(reviewer, scope: :saml_user)
        visit edit_grant_submission_review_path(grant, submission, review)
      end

      scenario 'completed review changes state' do
        expect(review.reload.assigned?).to be true
        grant.criteria.each do |criterion|
          find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
        end
        find("label[for='overall-#{random_score}']").click
        click_button 'Submit Your Review'
        expect(review.reload.submitted?).to be true
      end

      scenario 'redirects to MyReviews path' do
        grant.criteria.each do |criterion|
          find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
        end
        find("label[for='overall-#{random_score}']").click
        click_button 'Submit Your Review'
        expect(page).to have_text 'Review was successfully updated.'
        expect(page.current_path).to eql(profile_reviews_path)
      end

      context 'foundation form abide feedback' do
        scenario 'provides feedback when a required criterion score is not scored' do
          # login_as reviewer
          click_button 'Submit Your Review'

          expect(page).not_to have_text 'Review was successfully updated.'

          grant.required_criteria.each do |criterion|
            expect(page).to have_text "\'#{criterion.name}\' must be scored"
          end

          expect(review.reload.is_complete?).to be false
        end

        scenario 'does not provide feedback when an unrequired criterion is not scored' do
          click_button 'Submit Your Review'
          expect(page).not_to have_text 'Review was successfully updated.'
          expect(page).not_to have_text "\'#{grant.criteria.last.name}\' must be scored"
        end

        scenario 'provides feedback when overall impact score is not scored' do
          grant.criteria.each do |criterion|
            find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
          end
          click_button 'Submit Your Review'
          expect(page).not_to have_text 'Review was successfully updated.'
          expect(page).to have_text 'Overall Impact Score must be scored.'
          expect(review.reload.is_complete?).to be false
        end
      end

      context 'criterion clear button' do
        context 'submitted review' do
          scenario 'criterion clear button removes required criterion score' do
            criteria = []
            grant_criteria = grant.criteria
            grant_criteria.each do |criterion|
              find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
              criteria << criterion_id_selector(criterion).to_s
            end
            find("label[for='overall-#{random_score}']").click

            within("##{criteria.first}-button-group") do
              click_button('Clear')
            end

            click_button 'Submit Your Review'

            expect(page).to have_text "\'#{grant_criteria.first.name}\' must be scored"
          end

          scenario 'criterion clear button removes unrequired criterion score' do
            unrequired_criterion = grant.criteria.first
            unrequired_criterion.update(is_mandatory: false)
            unrequired_criterion_label = criterion_id_selector(unrequired_criterion)
            visit edit_grant_submission_review_path(grant, submission, review)

            grant.criteria.each do |criterion|
              find("label[for='#{criterion_id_selector(criterion)}-#{random_score}']").click
            end
            find("label[for='overall-#{random_score}']").click

            within("##{unrequired_criterion_label}-button-group") do
              click_button('Clear')
            end
            click_button 'Submit Your Review'
            expect(page).to have_text SUBMITTED_TEXT

            within("##{dom_id(review)}") do
              click_link(SUBMITTED_TEXT)
            end

            within("##{unrequired_criterion_label}-criterion") do
              expect(page).to have_text '-'
            end
          end
        end
      end
    end

    context 'draft scored review' do
      before(:each) do
        login_as(reviewer2, scope: :saml_user)
        visit edit_grant_submission_review_path(grant, submission, draft_scored_review)
      end

      context 'criterion clear button' do
        scenario 'criterion cleared score changes it to nil when saved' do
          criterion_to_clear = grant.criteria.first
          expect do
            within("##{criterion_id_selector(criterion_to_clear)}-button-group") do
              click_button('Clear')
              pause(time: 0.5)
            end

            accept_alert do
              click_button 'Save as Draft'
            end
            pause
          end.to change { draft_scored_review.reload.criteria_reviews.first.score }

          expect(draft_scored_review.criteria_reviews.first.score).to be nil
        end
      end
    end

    context 'failure' do
      let(:scored_review) do
        create(:submitted_scored_review_with_scored_mandatory_criteria_review, submission: submission,
                                                                               assigner: grant_admin,
                                                                               reviewer: new_grant_reviewer.reviewer)
      end

      before(:each) do
        grant.update(max_reviewers_per_submission: 2)
        login_as(scored_review.reviewer, scope: :saml_user)
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
      grant.update(max_reviewers_per_submission: 2)
      submitter = submission.submitter
      login_as(grant_admin, scope: :saml_user)
    end

    context 'applicants' do
      describe 'with one applicant replacing submitter' do
        scenario 'displays applicant where available' do
          submission_applicant.save
          submission.submission_applicants.first.delete
          visit grant_submissions_path(grant)

          expect(page).to have_text sortable_full_name(applicant)
          expect(page).not_to have_text sortable_full_name(submission.submitter)
        end
      end

      describe 'assigned submissions' do
        scenario 'displays applicant name' do
          submission_applicant.save
          submission.submission_applicants.first.delete
          review.save
          visit grant_submissions_path(grant)

          expect(page).to have_text sortable_full_name(applicant)
          expect(page).not_to have_text sortable_full_name(submission.submitter)
        end
      end
    end

    context 'draft submission' do
      scenario 'does not appear for assignment' do
        submission.reviews.delete_all
        submission.update(state: 'draft')
        visit grant_reviewers_path(grant)

        expect(page).not_to have_text submission.title
      end
    end

    context 'success' do
      before(:each) do
        review
        new_grant_reviewer.reviewer

        login_as(grant_admin, scope: :saml_user)
        visit grant_reviewers_path(grant)
      end

      scenario 'creates an assigned review' do
        dropdown_menu_id = "#manage_#{dom_id(new_grant_reviewer)}"
        dropdown_select_text = "#{full_name(grant.submissions.first.submitter)} - #{grant.submissions.first.title}"
        expect do
          find(dropdown_menu_id).hover
          wait_for_ajax
          find("#{dropdown_menu_id} li ul li", text: 'Assign Review').click
          pause
          within('#modal') do
            select(truncate(dropdown_select_text, length: 80), from: 'review[submission_id]')
            click_button('Assign Submission to Reviewer')
            pause
          end
        end.to change { grant.reviews.count }.by 1
        expect(grant.reviews.last.assigned?).to be true

        expect(page).to have_text "Review assigned. A notifcation email was sent to #{full_name(new_grant_reviewer.reviewer)}"
      end
    end

    context 'failure' do
      let(:submitter_reviewer) do
        create(:grant_reviewer, grant: grant,
                                reviewer: submission.submitter)
      end

      before(:each) do
        review
        submitter_reviewer
        login_as(grant_admin, scope: :saml_user)

        visit grant_reviewers_path(grant)
      end

      scenario 'does not include submission when reviewer is submitter' do
        dropdown_menu_id = "#manage_#{dom_id(submitter_reviewer)}"
        find(dropdown_menu_id).hover
        wait_for_ajax
        find("#{dropdown_menu_id} li ul li", text: 'Assign Review').click
        pause
        within('#modal') do
          expect(page).to have_text 'There are no submissions available to be assigned to this reviewer.'
          assert_no_selector('review[submission_id]')
        end
      end
    end
  end
end
