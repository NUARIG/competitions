require 'rails_helper'
include UsersHelper
include Turbo::FramesHelper

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
  let(:submitted_review)      { create(:submitted_scored_review_with_scored_mandatory_criteria_review,
                                          submission: submission,
                                          assigner: grant_admin,
                                          reviewer: grant.reviewers.first) }
  let(:new_reviewer)          { create(:grant_reviewer, grant: grant) }
  let(:new_review)            { create(:submitted_scored_review_with_scored_mandatory_criteria_review,
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
    t("pundit.default")
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
          end

          context 'with one submission' do
            context 'without reviews' do
              before(:each) do
                submission.touch
                visit grant_submissions_path(grant)
              end

              scenario 'can visit the submissions index page' do
                expect(page).not_to have_content not_authorized_text
              end

              scenario 'can view the submissions admin links' do
                within "##{dom_id(submission)}" do
                  expect(page).to have_content submission.title
                  expect(page).to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
                  expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
                  expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
                  expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
                end
              end

              scenario 'submission with no review shows dashes for score columns' do
                within "##{dom_id(submission)}" do
                  expect(page).to have_selector('.overall-impact', text: '-')
                  expect(page).to have_selector('.composite', text: '-')
                end
              end

              scenario 'submission with no review does not include the award checkbox' do
                within "##{dom_id(submission)}" do
                  expect(page).not_to have_selector('.awarded input[type="checkbox"]')
                end
              end

              scenario 'discarded submission is not included' do
                expect(page).to have_content submission.title
                submission.update(discarded_at: Time.now)

                visit grant_submissions_path(grant)
                expect(page).not_to have_content submission.title
              end
            end

            context 'with a review' do
              scenario 'submission with one review shows scores' do
                submitted_review.save
                visit grant_submissions_path(grant)

                within "##{dom_id(submission)}" do
                  expect(page).to have_selector('.overall-impact', text: submitted_review.overall_impact_score)
                  expect(page).to have_selector('.composite', text: (submitted_review.criteria_reviews.to_a.map(&:score).sum.to_f / submitted_review.criteria_reviews.count).round(2))
                end
              end

              scenario 'submission includes checkbox for award' do
                submitted_review.save
                visit grant_submissions_path(grant)

                within "##{dom_id(submission)}" do
                  expect(page).to have_field('grant_submission_submission[awarded]', disabled: false)
                end
              end

              scenario 'can award a submission' do
                can_award(grant, submission)
              end

              scenario 'can unaward a submission' do
                can_unaward(grant, submission)
              end
            end

            context 'with multiple reviews' do
              scenario 'submission shows proper scores' do
                reviews = [submitted_review, new_review]
                submitted_review.touch # trigger callback to recalculate scores. why is required here? callback should have happened on create of ea review.
                visit grant_submissions_path(grant)

                expected_average_overall = (reviews.map(&:overall_impact_score).compact.sum.to_f / 2).round(2)
                expected_composite       = (submission.criteria_reviews.to_a.map(&:score).sum.to_f / submission.criteria_reviews.count).round(2)

                within "##{dom_id(submission)}" do
                  expect(page).to have_selector('.overall-impact', text: expected_average_overall)
                  expect(page).to have_selector('.composite', text: expected_composite)
                end
              end

              scenario 'submission with an unscored review shows proper scores' do
                reviews = [submitted_review, new_review, unscored_review]
                visit grant_submissions_path(grant)

                expected_average_overall = (reviews.map(&:overall_impact_score).compact.sum.to_f / 2).round(2)
                expected_composite       = (submission.criteria_reviews.to_a.map(&:score).compact.sum.to_f / submission.criteria_reviews.count).round(2)

                within "##{dom_id(submission)}" do
                  expect(page).to have_selector('.overall-impact', text: expected_average_overall)
                  expect(page).to have_selector('.completed-reviews', text: '2 / 3')
                  expect(page).to have_selector('.composite', text: expected_composite)
                end
              end
            end
          end

          context 'with multiple submissions' do
            before(:each) do
              submitted_review.touch
              unreviewed_submission.update(user_updated_at: submission.user_updated_at + 1.minute)

              login_user grant_admin
              visit grant_submissions_path(grant)
            end

            scenario 'default sort by submission user_updated_at desc' do
              within('.submission', match: :first) do
                expect(page.find('.overall-impact', match: :first)).to have_text '-'
              end
            end

            scenario 'sorts overall_impact by scored submissions to top' do
              click_link('Overall Impact')
              within('.submission', match: :first) do
                expect(page.find('.overall-impact', match: :first)).to have_text submission.average_overall_impact_score
              end

              click_link('Overall Impact')
              within('.submission', match: :first) do
                expect(page.find('.overall-impact', match: :first)).to have_text submission.average_overall_impact_score
              end
            end

            scenario 'sorts composite_score by scored submissions to top' do
              click_link('Composite')
              within('.submission', match: :first) do
                expect(page.find(".composite", match: :first)).to have_text submission.composite_score
              end

              click_link('Composite')
              within('.submission', match: :first) do
                expect(page.find(".composite", match: :first)).to have_text submission.composite_score
              end
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

            scenario 'administrator submissions can be deleted' do
              accept_alert do
                click_link 'Delete', href: grant_submission_path(grant, admin_submission)
              end
              expect(page).to have_text 'Submission was deleted'
              
              accept_alert do
                click_link 'Delete', href: grant_submission_path(grant, editor_submission)
              end
              expect(page).to have_text 'Submission was deleted'
              
              accept_alert do
                click_link 'Delete', href: grant_submission_path(grant, viewer_submission)
              end
              expect(page).to have_text 'Submission was deleted'
            end
          end

          context 'export' do
            it 'unfound grant redirects to root' do
              visit '/grants/invalidgrant/submissions/export.xlsx'
              expect(current_path).to eq('/') 
              expect(page).to have_text 'Grant not found.'
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
          expect(page).not_to have_content not_authorized_text
        end

        scenario 'can view the submissions admin links' do
          visit grant_submissions_path(grant)
          expect(page).to have_link 'Export All Submissions', href: export_grant_submissions_path(grant, { format: 'xlsx' })

          within "##{dom_id(submission)}" do
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end

        scenario 'submission includes checkbox for award' do
          submitted_review.save
          visit grant_submissions_path(grant)

          within "##{dom_id(submission)}" do
            expect(page).to have_field('grant_submission_submission[awarded]', disabled: false)
          end
        end

        scenario 'can award a submission' do
          can_award(grant, submission)
        end

        scenario 'can unaward a submission' do
          can_unaward(grant, submission)
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

        context 'assign reviews' do
          before(:each) do
            unreviewed_submission.touch
            visit grant_submissions_path(grant)
          end 

          scenario 'can open modal to assign review to an unreviewed submission' do
            number_of_reviewers = grant.reviewers.length
            max_reviewers = grant.max_reviewers_per_submission

            within("##{dom_id(unreviewed_submission)}") do
              click_link('Assign')
            end
            within('#modal') do
              expect(page).to have_text "Assign Reviewers for #{unreviewed_submission.title.truncate(45)}"
              expect(page).to have_text "This submission can be assigned to #{max_reviewers} #{'reviewer'.pluralize(max_reviewers)} and has #{number_of_reviewers} #{'reviewer'.pluralize(number_of_reviewers)} available to review it."
            end
          end

          scenario 'can assign a review to an unreviewed submission' do
            reviewer_name = full_name(grant.reviewers.first)
            within("##{dom_id(unreviewed_submission)}") do
              click_link('Assign')
            end
            within('#modal') do
              select(reviewer_name, from: 'review[reviewer_id]')
              click_button('Assign to Review')
              expect(page).to have_text "Submission assigned for review. A notification email was sent to #{reviewer_name}."
              expect(page).to have_text "This submission has reached the limit for assigned reviews."
            end
          end

          scenario 'can assign multiple reviews' do
            reviewer_name = full_name(grant.reviewers.first)
            reviewer2_name = full_name(new_reviewer.reviewer)
            grant.update(max_reviewers_per_submission: 2, max_submissions_per_reviewer: 2)

            within("##{dom_id(unreviewed_submission)}") do
              click_link('Assign')
            end
            within('#modal') do
              "This submission can be assigned to 2"
              expect(page).to have_text "This submission can be assigned to 2 reviewers and has 2 reviewers available to review it."
              select(reviewer_name, from: 'review[reviewer_id]')
              click_button('Assign to Review')
              expect(page).to have_text "This submission can be assigned to 1 reviewer and has 1 reviewer available to review it."
              select(reviewer2_name, from: 'review[reviewer_id]')

              click_button('Assign to Review')
              wait_for_turbo
              expect(page).to have_text "Submission assigned for review. A notification email was sent to #{reviewer2_name}."
              expect(page).to have_text "This submission has reached the limit for assigned reviews."
            end
          end
        end
      end

      context 'editor' do
        before(:each) do
          login_user grant_editor
        end

        scenario 'can visit the submissions index page' do
          visit grant_submissions_path(grant)
          expect(page).not_to have_content not_authorized_text
        end

        scenario 'can view the appropriate admin links' do
          visit grant_submissions_path(grant)
          expect(page).to have_link 'Export All Submissions', href: export_grant_submissions_path(grant, { format: 'xlsx' })

          within "##{dom_id(submission)}" do
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end

        scenario 'can award a submission' do
          can_award(grant, submission)
        end

        scenario 'can unaward a submission' do
          can_unaward(grant, submission)
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
          expect(page).not_to have_content not_authorized_text
        end

        scenario 'can view the appropriate admin links' do
          visit grant_submissions_path(grant)
          expect(page).to have_link 'Export All Submissions', href: export_grant_submissions_path(grant, { format: 'xlsx' })

          within "##{dom_id(submission)}" do
            expect(page).to have_content submission.title
            expect(page).not_to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end

        scenario 'cannot awarded an unawarded submission' do
          submitted_review.save
          visit grant_submissions_path(grant)

          within "##{dom_id(submission)}" do
            expect(page).not_to have_field('grant_submission_submission[awarded]')
            expect(page).to have_unchecked_field('awarded', disabled: true)
          end
        end

        scenario 'cannot submit unawarded form' do
          submitted_review.save
          submission.update(awarded: true)
          visit grant_submissions_path(grant)

          within "##{dom_id(submission)}" do
            expect(page).not_to have_field('grant_submission_submission[awarded]')
            expect(page).to have_checked_field('awarded', disabled: true)
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

        scenario "redirects to the user's MySubmissions page" do
          expect(page).to have_text not_authorized_text
          expect(current_path).to eq(root_path)
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
            expect(page).to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
          end

          scenario 'can delete a submission' do
            unscored_review.save
            visit grant_submissions_path(grant)
            accept_alert do
              click_link 'Delete', href: grant_submission_path(grant, submission)
              pause
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
          expect(page).to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        scenario 'can delete a submission' do
          unscored_review.save

          visit grant_submissions_path(grant)
          accept_alert do
            click_link 'Delete', href: grant_submission_path(grant, submission)
            pause
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
          expect(page).to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
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
          expect(page).not_to have_link 'Assign', href: new_grant_submission_assign_review_path(grant, submission)
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
        pause
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

  def can_award(grant, submission)
    submitted_review.touch
    visit grant_submissions_path(grant)

    within "##{dom_id(submission)}" do
      expect(page).to have_unchecked_field('grant_submission_submission[awarded]')
      find_field('grant_submission_submission[awarded]').check
    end
    expect(page).to have_text 'has been awarded'
    expect(submission.reload.awarded).to be true
  end

  def can_unaward(grant, submission)
    submitted_review.touch
    submission.update(awarded: true)
    visit grant_submissions_path(grant)

    within "##{dom_id(submission)}" do
    expect(page).to have_checked_field('grant_submission_submission[awarded]')
    find_field('grant_submission_submission[awarded]').uncheck
    end
    expect(page).to have_text 'has been unawarded'
    expect(submission.reload.awarded).to be false
  end
end
