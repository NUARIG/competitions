require 'rails_helper'

RSpec.describe 'GrantSubmission::Submissions', type: :system do
  describe 'Published Open Grant', js: true do
    before(:each) do
      @grant = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @editor      = @grant.editors.first
      @applicant   = create(:user)
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
