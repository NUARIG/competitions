require 'rails_helper'

RSpec.describe 'GrantSubmission::Submissions', type: :system, js: true do
  context '#index' do
    before(:each) do
      @grant        = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @submission   = @grant.submissions.first
      @system_admin = create(:system_admin_user)
      @grant_admin  = @grant.editors.first
      @grant_editor = @grant.editors.second
      @grant_viewer = @grant.editors.third
    end

    context 'published grant' do
      context 'system_admin' do
        before(:each) do
          login_as(@system_admin)
        end

        scenario 'can visit the submissions index page' do
          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end

      context 'grant_admin' do
        scenario 'can visit the submissions index page' do
          login_as(@grant_admin)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end

      context 'editor' do
        scenario 'can visit the submissions index page' do
          login_as(@grant_editor)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end

      context 'viewer' do
        scenario 'can visit the submissions index page' do
          login_as(@grant_viewer)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end
    end

    context 'draft grant' do
      before(:each) do
        @grant.update_attributes(state: 'draft')
      end

      context 'system_admin' do
        scenario 'can visit the submissions index page' do
          login_as(@system_admin)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end

      context 'grant_admin' do
        scenario 'can visit the submissions index page' do
          login_as(@grant_admin)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end

      context 'editor' do
        scenario 'can visit the submissions index page' do
          login_as(@grant_editor)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end

      context 'viewer' do
        scenario 'can visit the submissions index page' do
          login_as(@grant_viewer)

          visit grant_submissions_path(@grant)
          expect(page).to have_content @submission.title
          expect(page).to have_link 'Reviews', href: grant_submission_reviews_path(@grant, @submission)
          expect(page).not_to have_link 'Edit', href: edit_grant_submission_path(@grant, @submission)
          expect(page).not_to have_link 'Delete', href: grant_submission_path(@grant, @submission)
        end
      end
    end
  end

  context 'apply' do
    describe 'Published Open Grant', js: true do
      before(:each) do
        @grant     = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
        @editor    = @grant.editors.first
        @applicant = create(:user)
      end

      context 'applicant' do
        before(:each) do
          login_as(@applicant)
          visit grant_apply_path(@grant)
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
          short_text_question = @grant.questions.where(response_type: 'short_text').first
          short_text_question.update_attribute(:is_mandatory, true)

          find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
          find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
          click_button 'Submit'
          expect(page).not_to have_content 'You successfully applied'
        end
      end
    end

    describe 'Draft Grant', js: true do
      before(:each) do
        @draft_grant = create(:draft_grant)
        @editor      = @draft_grant.editors.first
        @applicant   = create(:user)
      end

      context 'editor' do
        before(:each) do
          login_as(@editor)
          visit grant_apply_path(@draft_grant)
        end

        scenario 'can visit apply page' do
          expect(page).not_to have_content 'You are not authorized to perform this action.'
        end
      end

      context 'applicant' do
        before(:each) do
          login_as(@applicant)
          visit grant_apply_path(@draft_grant)
        end

        scenario 'can visit apply page' do
          expect(page).to have_content 'You are not authorized to perform this action.'
        end
      end
    end
  end
end
