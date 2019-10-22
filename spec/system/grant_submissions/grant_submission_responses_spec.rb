require 'rails_helper'

RSpec.describe 'GrantSubmission::Responses', type: :system do
  describe 'Published Open Grant', js: true do
    before(:each) do
      @grant     = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
      @applicant = create(:user)

      login_as(@applicant)
      visit grant_apply_path(@grant)
      find_field('Your Project\'s Title', with: '').set(Faker::Lorem.sentence)
    end

    scenario 'requires response mandatory short_text question' do
      short_text_question = @grant.questions.where(response_type: 'short_text').first
      short_text_question.update_attribute(:is_mandatory, true)

      find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
      find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
      click_button 'Submit'
      expect(page).not_to have_content 'You successfully applied'
      expect(page).to have_content "Response to '#{short_text_question.text}' is required."
    end

    scenario 'requires response mandatory number question' do
      number_question = @grant.questions.where(response_type: 'number').first
      number_question.update_attribute(:is_mandatory, true)

      find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
      find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
      click_button 'Submit'
      expect(page).not_to have_content 'You successfully applied'
      expect(page).to have_content "Response to '#{number_question.text}' is required."
    end

    scenario 'number question requires a number response' do
      number_question = @grant.questions.where(response_type: 'number').first

      find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
      find_field(number_question.text, with: '').set('Ten')
      find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
      click_button 'Submit'
      expect(page).not_to have_content 'You successfully applied'
      expect(page).to have_content "Response to '#{number_question.text}' must be a number."
    end

    scenario 'requires response mandatory long_text question' do
      long_text_question = @grant.questions.where(response_type: 'long_text').first
      long_text_question.update_attribute(:is_mandatory, true)

      find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
      find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
      click_button 'Submit'
      expect(page).not_to have_content 'You successfully applied'
      expect(page).to have_content "Response to '#{long_text_question.text}' is required."
    end

    scenario 'requires response mandatory pick_one question' do
      multiple_choice_question = @grant.questions.where(response_type: 'pick_one').first
      multiple_choice_question.update_attribute(:is_mandatory, true)

      find_field('Short Text Question', with:'').set(Faker::Lorem.sentence)
      find_field('Number Question', with:'').set(Faker::Number.number(digits: 10))
      find_field('Long Text Question', with:'').set(Faker::Lorem.paragraph_by_chars(number: 1000))
      click_button 'Submit'
      expect(page).not_to have_content 'You successfully applied'
      expect(page).to have_content "A selection for '#{multiple_choice_question.text}' is required."
    end

    scenario 'accepts a pick_one response' do
      multiple_choice_question = @grant.questions.where(response_type: 'pick_one').first
      first_option_text        = multiple_choice_question.multiple_choice_options.first.text

      select("#{first_option_text}", from: multiple_choice_question.text)
      click_button 'Submit'
      expect(page).to have_content 'You successfully applied'
    end
  end
end
