require 'rails_helper'
include UsersHelper

RSpec.describe 'GrantSubmission::Submissions', type: :system, js: true do 
  let(:grant)                 { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:submission)            { grant.submissions.first }
  let(:applicant)             { submission.applicant }
  let(:system_admin)          { create(:system_admin_user) }
  let(:grant_admin)           { grant.administrators.first }
  let(:grant_editor)          { grant.administrators.second }
  let(:grant_viewer)          { grant.administrators.third }
  let(:new_applicant)         { create(:user) }
  let(:draft_submission)      { create(:draft_submission_with_responses,
                                         grant: grant,
                                         form: grant.form) }
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

  context '#index' do
    context 'published grant' do
      context 'with submitted submission' do
        context 'system_admin' do
          before(:each) do
            login_as(system_admin)
          end

          scenario 'can visit the submissions index page' do
            visit grant_submissions_path(grant)
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end

          context 'with reviews' do
            scenario 'submission with no review shows dashes' do
              visit grant_submissions_path(grant)
              overall   = page.find("td[data-overall-impact='#{submission.id}']")
              composite = page.find("td[data-composite='#{submission.id}']")
              expect(overall).to have_text '-'
              expect(composite).to have_text '-'
            end

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
              unreviewed_submission.save

              login_as(grant_admin)
              visit grant_submissions_path(grant)
            end

            scenario 'sorts overall_impact by scored submissions to top' do
              expect(page.find(".average", match: :first)).to have_text '-'

              click_link('Overall Impact')
              expect(page.find(".average", match: :first)).to have_text submission.average_overall_impact_score

              click_link('Overall Impact')
              expect(page.find(".average", match: :first)).to have_text submission.average_overall_impact_score
            end

            scenario 'sorts composite_score by scored submissions to top' do
              expect(page.find(".composite", match: :first)).to have_text '-'

              click_link('Composite')
              expect(page.find(".composite", match: :first)).to have_text submission.composite_score

              click_link('Composite')
              expect(page.find(".composite", match: :first)).to have_text submission.composite_score
            end
          end
        end

        context 'grant_admin' do
          scenario 'can visit the submissions index page' do
            login_as(grant_admin)

            visit grant_submissions_path(grant)
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end
      end

      context 'editor' do
        scenario 'can visit the submissions index page' do
          login_as(grant_editor)

          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end
      end

      context 'viewer' do
        scenario 'can visit the submissions index page' do
          login_as(grant_viewer)

          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).not_to have_link 'Assign Reviews', href: grant_submission_reviews_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end
      end

      context 'applicant' do
        before(:each) do
          other_submission
          login_as(applicant)

          visit grant_submissions_path(grant)
        end

        scenario 'includes link to own submission' do
          expect(page).to have_content submission.title
        end

        scenario 'does not have admin links' do
          expect(page).not_to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        scenario 'does not include other applicant submission' do
          expect(page).not_to have_content other_submission.title
        end

        scenario 'does not include score columns' do
          expect(page).not_to have_content 'Reviews'
          expect(page).not_to have_content 'Overall Impact'
          expect(page).not_to have_content 'Composite'
        end
      end
    end

    context 'draft grant' do
      before(:each) do
        grant.update_attributes(state: 'draft')
      end

      context 'with submitted submission' do
        context 'system_admin' do
          scenario 'can visit the submissions index page' do
            login_as(system_admin)

            visit grant_submissions_path(grant)
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end

        context 'grant_admin' do
          scenario 'can visit the submissions index page' do
            login_as(grant_admin)

            visit grant_submissions_path(grant)
            expect(page).to have_content submission.title
            expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end
      end

      context 'editor' do
        scenario 'can visit the submissions index page' do
          login_as(grant_editor)

          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end
      end

      context 'viewer' do
        scenario 'can visit the submissions index page' do
          login_as(grant_viewer)

          visit grant_submissions_path(grant)
          expect(page).to have_content submission.title
          expect(page).to have_link 'Assign Reviews', href: grant_reviewers_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end
      end
    end

    context 'search' do
      before(:each) do
        draft_submission
        login_as(grant_admin)
      end

      scenario 'filters on applicant last name' do
        visit grant_submissions_path(grant)
        expect(page).to have_content sortable_full_name(draft_submission.applicant)
        find_field('Search Applicant Last Name or Project Title').set(applicant.last_name)
        click_button 'Search'
        expect(page).not_to have_content sortable_full_name(draft_submission.applicant)
      end

      scenario 'filters on application title' do
        visit grant_submissions_path(grant)
        expect(page).to have_content draft_submission.title
        find_field('Search Applicant Last Name or Project Title').set(submission.title.truncate_words(2, omission: ''))
        click_button 'Search'
        expect(page).not_to have_content draft_submission.title
      end
    end
  end

  context 'apply' do
    describe 'Published Open Grant', js: true do
      context 'applicant' do
        before(:each) do
          login_as(new_applicant)
          visit grant_apply_path(grant)
        end

        scenario 'can visit apply page' do
          expect(page).not_to have_content 'You are not authorized to perform this action.'
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
          short_text_question.update_attribute(:is_mandatory, true)

          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
          click_button 'Submit'
          expect(page).not_to have_content 'You successfully applied'
        end
      end

      context '#update' do
        before(:each) do
          submission.update_attribute(:state, 'draft')
          grant.questions.where(response_type: 'short_text').first.update_attribute(:is_mandatory, true)
          login_as(applicant)
        end

        context 'draft submission' do
          scenario 'can visit edit path for draft submission' do
            visit edit_grant_submission_path(grant, submission)
            expect(page).to have_content 'Editing Application'
            expect(page).to have_current_path edit_grant_submission_path(grant, submission)
          end

          scenario 'can save valid submission as draft' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set(Faker::Lorem.sentence)
            click_button 'Save as Draft'
            expect(page).to have_content 'Submission was successfully updated and saved.'
          end

          scenario 'can save an incomplete submission as draft' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set('')
            click_button 'Save as Draft'
            expect(page).to have_content 'Submission was successfully updated and saved.'
          end

          scenario 'cannot submit a submission with an error' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set('')
            click_button 'Submit'
            expect(page).to have_content 'Your responses have highlighted errors.'
            expect(submission.reload.draft?).to be true
          end

          scenario 'can submit a valid submission' do
            grant.questions.where(response_type: 'short_text').first.update_attribute(:is_mandatory, true)
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set(Faker::Lorem.sentence)
            click_button 'Submit'
            expect(page).to have_content 'You successfully applied.'
            expect(submission.reload.submitted?).to be true
          end
        end

        context 'submitted submission' do
          scenario 'cannot vist edit path for submitted submission' do
            submission.update_attribute(:state, 'submitted')
            visit edit_grant_submission_path(grant, submission)
            expect(page).to have_content 'You are not authorized to perform this action'
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
          login_as(draft_grant.administrators.first)
          visit grant_apply_path(draft_grant)
        end

        scenario 'can visit apply page' do
          expect(page).not_to have_content 'You are not authorized to perform this action.'
        end
      end

      context 'applicant' do
        before(:each) do
          login_as(new_applicant)
          visit grant_apply_path(draft_grant)
        end

        scenario 'can not visit apply page' do
          expect(page).to have_content 'You are not authorized to perform this action.'
        end
      end
    end
  end
end
