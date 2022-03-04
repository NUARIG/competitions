require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantSubmission::Submissions', type: :system, js: true do
  let(:grant)                 { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:submission)            { grant.submissions.first }
  let(:submitter)             { submission.submitter }
  let(:sa_submitter)          { create(:grant_submission_submission_applicant,
                                        submission: submission,
                                        applicant: submitter) }
  let(:applicant)             { create(:saml_user) }
  let(:sa_applicant)          { create(:grant_submission_submission_applicant,
                                        submission: submission,
                                        applicant: applicant) }
  let(:system_admin)          { create(:system_admin_saml_user) }
  let(:grant_admin)           { grant.administrators.first }
  let(:grant_editor)          { grant.administrators.second }
  let(:grant_viewer)          { grant.administrators.third }
  let(:new_submitter)         { create(:saml_user) }
  let(:draft_submission)      { create(:draft_submission_with_responses,
                                        grant: grant,
                                        form: grant.form) }
  let(:draft_sa_submitter)    { create(:grant_submission_submission_applicant,
                                        submission: draft_submission,
                                        applicant:  draft_submission.submitter) }
  let(:draft_applicant)       { create(:saml_user) }
  let(:draft_sa_applicant)    { create(:grant_submission_submission_applicant,
                                        submission: draft_submission,
                                        applicant: draft_applicant) }
  let(:draft_grant)           { create(:draft_grant) }
  let(:other_submission)      { create(:grant_submission_submission, grant: grant) }
  let(:review)                { create(:scored_review_with_scored_mandatory_criteria_review,
                                        submission: submission,
                                        assigner: grant_admin,
                                        reviewer: grant.reviewers.first) }
  let(:new_reviewer)          { create(:grant_reviewer, grant: grant) }
  let(:new_review)            { create(:scored_review_with_scored_mandatory_criteria_review,
                                        submission: submission,
                                        assigner: grant_admin,
                                        reviewer: new_reviewer.reviewer) }
  let(:unscored_review)       { create(:incomplete_review,
                                        submission: submission,
                                        assigner: grant_admin,
                                        reviewer: create(:grant_reviewer, grant: grant).reviewer ) }
  let(:unreviewed_submission) { create(:submission_with_responses,
                                        grant: grant,
                                        form: grant.form) }
  let(:admin_submission)      { create(:submission_with_responses,
                                        grant: grant,
                                        form: grant.form,
                                        submitter: grant_admin,
                                        created_at: grant.submission_close_date - 1.hour) }
  let(:editor_submission)     { create(:submission_with_responses,
                                        grant: grant,
                                        form: grant.form,
                                        submitter: grant_editor,
                                        created_at: grant.submission_close_date - 1.hour) }
  let(:viewer_submission)     { create(:submission_with_responses,
                                        grant: grant,
                                        form: grant.form,
                                        submitter: grant_viewer,
                                        created_at: grant.submission_close_date - 1.hour) }

  def not_authorized_text
    'You are not authorized to perform this action.'
  end

  def successfully_saved_submission_message
    'Draft submission was saved. It can not be reviewed until it has been submitted.'
  end

  def successfully_submitted_submission_message
    'You successfully applied'
  end

  def successfully_updated_draft_submission_message
    'Draft submission was successfully updated and saved. It can not be reviewed until it has been submitted.'
  end

  context '#index' do
    context 'published grant' do
      context 'with submitted submission' do
        context 'system_admin' do
          before(:each) do
            login_user system_admin
            visit grant_submissions_path(grant)
          end

          scenario 'can visit the submissions index page' do
            visit grant_submissions_path(grant)
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end

          scenario 'submission with no review shows dashes' do
            overall   = page.find("td[data-overall-impact='#{submission.id}']")
            composite = page.find("td[data-composite='#{submission.id}']")
            expect(overall).to have_text '-'
            expect(composite).to have_text '-'
          end

          scenario 'discarded submission is not included' do
            expect(page).to have_content submission.title
            submission.update(discarded_at: Time.now)

            visit grant_submissions_path(grant)
            expect(page).not_to have_content submission.title
          end

          context 'with reviews' do
            scenario 'submission with one review shows scores' do
              review.save
              visit grant_submissions_path(grant)
              overall   = page.find("td[data-overall-impact='#{submission.id}']")
              composite = page.find("td[data-composite='#{submission.id}']")
              expect(overall).to have_text review.overall_impact_score
              expect(composite).to have_text (review.criteria_reviews.to_a.map(&:score).sum.to_f / review.criteria_reviews.count).round(2)
            end

            scenario 'submission with one review shows scores' do
              review.save
              visit grant_submissions_path(grant)
              overall   = page.find("td[data-overall-impact='#{submission.id}']")
              composite = page.find("td[data-composite='#{submission.id}']")
              expect(overall).to have_text review.overall_impact_score
              expect(composite).to have_text (review.criteria_reviews.to_a.map(&:score).sum.to_f / review.criteria_reviews.count).round(2)
            end

            scenario 'submission with multiple reviews shows proper scores' do
              reviews = [review, new_review]
              review.save
              visit grant_submissions_path(grant)
              overall   = page.find("td[data-overall-impact='#{submission.id}']")
              composite = page.find("td[data-composite='#{submission.id}']")

              expected_average_overall = (reviews.map(&:overall_impact_score).compact.sum.to_f / 2).round(2)
              expected_composite       = (submission.criteria_reviews.to_a.map(&:score).sum.to_f / submission.criteria_reviews.count).round(2)

              expect(overall).to have_text expected_average_overall
              expect(composite).to have_text expected_composite
            end

            scenario 'submission with multiple reviews shows proper scores' do
              reviews = [review, new_review, unscored_review]
              visit grant_submissions_path(grant)

              overall   = page.find("td[data-overall-impact='#{submission.id}']")
              composite = page.find("td[data-composite='#{submission.id}']")
              completed = page.find("div[data-completed-reviews='#{submission.id}'")

              expected_average_overall = (reviews.map(&:overall_impact_score).compact.sum.to_f / 2).round(2)
              expected_composite       = (submission.criteria_reviews.to_a.map(&:score).compact.sum.to_f / submission.criteria_reviews.count).round(2)

              expect(overall).to have_text expected_average_overall
              expect(completed).to have_text '2 / 3'
              expect(composite).to have_text expected_composite
            end
          end

          context 'with multiple submissions' do
            before(:each) do
              review.save
              unreviewed_submission.update(user_updated_at: submission.user_updated_at + 1.minute)

              login_user grant_admin
              visit grant_submissions_path(grant)
            end

            scenario 'default sort by submission user_updated_at desc' do
              expect(page.find(".average", match: :first)).to have_text '-'
            end

            scenario 'sorts overall_impact by scored submissions to top' do
              click_link('Overall Impact')
              expect(page.find(".average", match: :first)).to have_text submission.average_overall_impact_score

              click_link('Overall Impact')
              expect(page.find(".average", match: :first)).to have_text submission.average_overall_impact_score
            end

            scenario 'sorts composite_score by scored submissions to top' do
              click_link('Composite')
              expect(page.find(".composite", match: :first)).to have_text submission.composite_score

              click_link('Composite')
              expect(page.find(".composite", match: :first)).to have_text submission.composite_score
            end
          end

          context 'administrator submissions' do
            before(:each) do
              admin_submission.save
              editor_submission.save
              viewer_submission.save
              visit grant_submissions_path(grant)
            end

            scenario 'published grant includes proper submission delete links' do
              expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, admin_submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, editor_submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, viewer_submission)
            end
          end
        end
      end

      context 'grant_admin' do
        before(:each) do
          login_user grant_admin
          visit grant_submissions_path(grant)
        end

        scenario 'can visit the submissions index page' do
          login_user grant_admin

          expect(page).to have_content submission.title
          expect(page).to have_link 'Export All Submissions', href: grant_submissions_path(grant, {format: 'xlsx'})
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        context 'administrator submissions' do
          before(:each) do
            admin_submission.save
            editor_submission.save
            viewer_submission.save
            visit grant_submissions_path(grant)
          end

          scenario 'includes proper submission delete links' do
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, admin_submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, editor_submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, viewer_submission)
          end
        end
      end

      context 'editor' do
        before(:each) do
          login_user grant_editor
        end

        scenario 'can visit the submissions index page' do
          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Export All Submissions', href: grant_submissions_path(grant, {format: 'xlsx'})
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        context 'administrator submissions' do
          before(:each) do
            admin_submission.save
            editor_submission.save
            viewer_submission.save
            visit grant_submissions_path(grant)
          end

          scenario 'published grant includes proper submission delete links' do
            has_no_submission_delete_links(grant, submission, admin_submission, editor_submission, viewer_submission)
          end
        end
      end

      context 'viewer' do
        before(:each) do
          login_user grant_viewer
        end

        scenario 'can visit the submissions index page' do
          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Export All Submissions', href: grant_submissions_path(grant, {format: 'xlsx'})
          expect(page).not_to have_link 'Assign Reviews', href: grant_submission_reviews_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        context 'administrator submissions' do
          before(:each) do
            admin_submission.save
            editor_submission.save
            viewer_submission.save
            visit grant_submissions_path(grant)
          end

          scenario 'published grant includes proper submission delete links' do
            has_no_submission_delete_links(grant, submission, admin_submission, editor_submission, viewer_submission)
          end
        end
      end

      context 'submitter' do
        before(:each) do
          other_submission.save
          login_user submitter

          visit grant_submissions_path(grant)
        end

        context 'submitted submission' do
          scenario 'includes link to own submission' do
            expect(page).to have_content submission.title
          end

          scenario 'does not have admin links' do
            expect(page).not_to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Save all Submissions', href: grant_submissions_path(grant)
          end

          scenario 'does not include other submitter submission' do
            expect(page).not_to have_content other_submission.title
          end

          scenario 'does not include score columns' do
            expect(page).not_to have_content 'Reviews'
            expect(page).not_to have_content 'Overall Impact'
            expect(page).not_to have_content 'Composite'
          end
        end

        context 'draft submission' do
          before(:each) do
            submission.update(state: 'draft')
            visit grant_submissions_path(grant)
          end

          scenario 'includes edit links' do
            expect(page).to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          end

          scenario 'does not have admin links' do
            expect(page).not_to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
            expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end
      end
    end

    context 'draft grant' do
      before(:each) do
        grant.update(state: 'draft')
      end

      context 'with submitted submission' do
        context 'system_admin' do
          before(:each) do
            login_user system_admin
          end

          scenario 'can visit the submissions index page' do
            visit grant_submissions_path(grant)

            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
          end

          scenario 'can delete a submission' do
            unscored_review.save
            visit grant_submissions_path(grant)
            accept_alert do
              click_link 'Delete', href: grant_submission_path(grant, submission)
            end
            expect(page).to have_text 'Submission was deleted'
          end

          context 'administrator submissions' do
            before(:each) do
              admin_submission.save
              editor_submission.save
              viewer_submission.save
              visit grant_submissions_path(grant)
            end

            scenario 'draft grant includes proper submission delete links' do
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, admin_submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, editor_submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, viewer_submission)
            end
          end
        end
      end

      context 'grant_admin' do
          before(:each) do
           login_user grant_admin
          end

          scenario 'can visit the submissions index page' do
            visit grant_submissions_path(grant)

            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
          end

          scenario 'can delete a submission' do
            unscored_review.save

            visit grant_submissions_path(grant)
            accept_alert do
              click_link 'Delete', href: grant_submission_path(grant, submission)
            end
            expect(page).to have_text 'Submission was deleted'
          end

          context 'administrator submissions' do
            before(:each) do
              admin_submission.save
              editor_submission.save
              viewer_submission.save
              visit grant_submissions_path(grant)
            end

            scenario 'includes proper submission delete links' do
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, admin_submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, editor_submission)
              expect(page).to have_link 'Delete', href: grant_submission_path(grant, viewer_submission)
            end
          end
      end

      context 'editor' do
        before(:each) do
          login_user grant_editor
        end

        scenario 'can visit the submissions index page' do
          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        context 'administrator submissions' do
          before(:each) do
            admin_submission.save
            editor_submission.save
            viewer_submission.save
            visit grant_submissions_path(grant)
          end

          scenario 'includes proper submission delete links' do
            has_no_submission_delete_links(grant, submission, admin_submission, editor_submission, viewer_submission)
          end
        end
      end

      context 'viewer' do
        before(:each) do
          login_user grant_viewer
        end

        scenario 'can visit the submissions index page' do
          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        context 'administrator submissions' do
          before(:each) do
            admin_submission.save
            editor_submission.save
            viewer_submission.save
            visit grant_submissions_path(grant)
          end

          scenario 'draft grant includes proper submission delete links' do
            has_no_submission_delete_links(grant, submission, admin_submission, editor_submission, viewer_submission)
          end
        end
      end

      context 'submitter' do
        scenario 'cannot visit submissions page' do
          login_user submitter
          visit grant_submissions_path(grant)
          expect(page).to have_text not_authorized_text
        end
      end

      context 'applicant' do
        scenario 'cannot visit submissions page' do
          login_user applicant
          visit grant_submissions_path(grant)
          expect(page).to have_text not_authorized_text
        end
      end

    end

    context 'search' do
      before(:each) do
        draft_submission
        draft_sa_applicant
        login_user grant_admin
      end

      scenario 'filters on submitter last name' do
        visit grant_submissions_path(grant)
        expect(page).to have_content sortable_full_name(draft_submission.applicants.first)
        page.fill_in 'q_applicants_first_name_or_applicants_last_name_or_title_cont_all', with: submission.applicants.first.last_name
        click_button 'Search'
        expect(page).not_to have_content sortable_full_name(draft_submission.applicants.first)
      end

      scenario 'filters on application title' do
        visit grant_submissions_path(grant)
        expect(page).to have_content draft_submission.title
        page.fill_in 'q_applicants_first_name_or_applicants_last_name_or_title_cont_all', with: submission.title.truncate_words(2, omission: '')
        click_button 'Search'
        expect(page).not_to have_content draft_submission.title
      end
    end
  end

  context 'apply' do
    describe 'Published Open Grant', js: true do
      context 'submitter' do
        before(:each) do
          login_user new_submitter
          visit grant_apply_path(grant)
        end

        scenario 'can visit apply page' do
          expect(page).not_to have_content not_authorized_text
        end

        scenario 'can submit a valid submission' do
          find_field('Your Project\'s Title', with: '').set(Faker::Lorem.sentence)
          find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
          click_button 'Submit'
          expect(page).to have_content 'You successfully applied'
        end

        scenario 'requires a title' do
          short_text_question = grant.questions.where(response_type: 'short_text').first
          short_text_question.update(is_mandatory: true)

          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
          click_button 'Submit'
          expect(page).not_to have_content 'You successfully applied'
        end

        context 'instructions' do
          scenario 'displays question instructions' do
            expect(page).to have_content grant.questions.first.instruction
          end
        end
      end

      context '#update' do
        before(:each) do
          grant.questions.where(response_type: 'short_text').first.update(is_mandatory: true)
          login_user submitter
        end

        context 'draft submission' do
          before(:each) do
            submission.update(state: 'draft')
          end

          scenario 'can visit edit path for draft submission' do
            visit edit_grant_submission_path(grant, submission)
            expect(page).to have_content 'Edit Your Submission'
            expect(page).to have_current_path edit_grant_submission_path(grant, submission)
          end

          scenario 'can save valid submission as draft' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set(Faker::Lorem.sentence)
            click_button 'Save as Draft'
            expect(page).to have_content successfully_updated_draft_submission_message
          end

          scenario 'can save an incomplete submission as draft' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set('')
            click_button 'Save as Draft'
            expect(page).to have_content successfully_updated_draft_submission_message
          end

          scenario 'cannot submit a submission with an error' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set('')
            click_button 'Submit'
            expect(page).to have_content 'Your responses have highlighted errors.'
            expect(submission.reload.draft?).to be true
          end

          scenario 'can submit a valid submission' do
            grant.questions.where(response_type: 'short_text').first.update(is_mandatory: true)
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set(Faker::Lorem.sentence)
            click_button 'Submit'
            expect(page).to have_content 'You successfully applied.'
            expect(submission.reload.submitted?).to be true
          end
        end

        context 'submitted submission' do
          scenario 'cannot vist edit path for submitted submission' do
            visit edit_grant_submission_path(grant, submission)
            expect(page).to have_content not_authorized_text
          end
        end
      end
    end

    describe 'Draft Grant', js: true do
      before(:each) do
        draft_grant
      end

      context 'editor' do
        before(:each) do
          login_user(draft_grant.admins.first)
          visit grant_apply_path(draft_grant)
        end

        scenario 'can visit apply page' do
          expect(page).not_to have_content not_authorized_text
        end
      end

      context 'submitter' do
        before(:each) do
          login_user new_submitter
          visit grant_apply_path(draft_grant)
        end

        scenario 'can not visit apply page' do
          expect(page).to have_content not_authorized_text
        end
      end
    end
  end

  context 'show' do
    context 'submitter' do
      context 'draft' do
        before(:each) do
          login_user draft_submission.submitter
          draft_sa_submitter
          visit grant_submission_path(draft_submission.grant, draft_submission)
        end

        it 'displays proper headers' do
          expect(page).to have_content 'Your Submission'
          expect(page).to have_content draft_submission.title
        end

        it 'includes link to edit' do
          expect(page).to have_content 'Edit This Submission'
        end
      end

      context 'submitted' do
        before(:each) do
          login_user submission.submitter
          visit grant_submission_path(grant, submission)
        end

        it 'does not include link to edit' do
          expect(page).not_to have_content 'Edit This Submission'
        end
      end
    end

    context 'admin' do
      before(:each) do
        login_user grant_admin
      end

      context 'draft' do
        before(:each) do
          visit grant_submission_path(draft_submission.grant, draft_submission)
        end

        it 'displays proper headers' do
          expect(page).to have_content 'Submission'
          expect(page).to have_content draft_submission.title
        end

        it 'does not include link to edit' do
          expect(page).not_to have_content 'Edit This Submission'
        end
      end

      context 'submitted' do
        before(:each) do
          visit grant_submission_path(grant, submission)
        end

        it 'does not include link to edit' do
          expect(page).not_to have_content 'Edit This Submission'
        end
      end
    end
  end

  def has_no_submission_delete_links(grant, submission, admin_submission, editor_submission, viewer_submission)
    expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
    expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, admin_submission)
    expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, editor_submission)
    expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, viewer_submission)
  end
end
