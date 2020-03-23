require 'rails_helper'

RSpec.describe 'GrantSubmission::Submissions', type: :system, js: true do
  let(:grant)            { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:submission)       { grant.submissions.first }
  let(:applicant)        { submission.applicant }
  let(:system_admin)     { create(:system_admin_user) }
  let(:grant_admin)      { grant.administrators.first }
  let(:grant_editor)     { grant.administrators.second }
  let(:grant_viewer)     { grant.administrators.third }
  let(:new_applicant)    { create(:user) }
  let(:draft_grant)      { create(:draft_grant) }
  let(:other_submission) { create(:grant_submission_submission, grant: grant) }

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
            expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
            expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
            expect(page).to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
            expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
          end
        end

        context 'grant_admin' do
          scenario 'can visit the submissions index page' do
            login_as(grant_admin)

            visit grant_submissions_path(grant)
            expect(page).to have_content submission.title
            expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
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
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
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
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end
      end

      context 'applicant' do
        before(:each) do
          # submission_by_other_applicant = create(:grant_submission_submission, grant: grant)
          other_submission
          login_as(applicant)

          visit grant_submissions_path(grant)
        end

        scenario 'includes link to own submission' do
          expect(page).to have_content submission.title
        end

        scenario 'does not have admin links' do
          expect(page).not_to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end

        scenario 'does not include other applicant submission' do
          expect(page).not_to have_content other_submission.title
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
            expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
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
            expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
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
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
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
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(grant, submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Switch to Draft', href: unsubmit_grant_submission_path(grant, submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(grant, submission)
        end
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
          login_as(applicant)
        end

        context 'draft submission' do
          scenario 'can visit edit path for draft submission' do
            visit edit_grant_submission_path(grant, submission)
            expect(page).to have_content 'Editing Application'
            expect(page).to have_current_path edit_grant_submission_path(grant, submission)
          end

          scenario 'can save submission as draft' do
            visit edit_grant_submission_path(grant, submission)
            find_field('Short Text Question').set(Faker::Lorem.sentence)
            click_button 'Save as Draft'
            expect(page).to have_content 'Submission was successfully updated and saved.'
          end

          scenario 'cannot submit a submission with an error' do
            grant.questions.where(response_type: 'short_text').first.update_attribute(:is_mandatory, true)
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
