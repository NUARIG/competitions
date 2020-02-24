require 'rails_helper'

RSpec.describe 'GrantSubmission::Questions', type: :system do
  add_question_text = 'Add a Question to this Section'
  add_section_text  = 'Add a Section'

  describe 'Grant Edit question', js: true do
    before(:each) do
      @grant = create(:draft_open_grant)
      @form  = @grant.form
      @admin = @grant.administrators.first

      login_as(@admin)
      visit edit_grant_form_path(@grant, @form)
    end

    scenario 'cannot be added when invalid' do
      expect do
        click_link add_question_text
        click_button 'Save'
      end.not_to (change{@grant.questions.count})

      expect(page).to have_text 'Question Text is required'
      expect(page).to have_text 'Question Response Type must be selected'
    end

    scenario 'can be added to an existing section' do
      expect do
        new_question_text = Faker::Lorem.sentence
        click_link add_question_text
        find_field('Question Text', with: '').set(new_question_text)
        find_field('Type of Response', with: '').select('Number')
        click_button 'Save'
      end.to (change{@grant.questions.count}).by 1
      expect(page).to have_text 'Submission Form successfully updated'
    end

    scenario 'it requires questions in a section to have unique text' do
      find_field('Question Text', with: "#{@grant.questions.second.text}").set("#{@grant.questions.first.text}")
      click_button 'Save'
      expect(page).not_to have_text 'Submission Form successfully updated'
      expect(page).to have_text I18n.t('activerecord.errors.models.grant_submission/question.attributes.text.taken')
    end

    scenario 'it allows duplicate question text between sections' do
      click_link add_section_text
      find_field('Title', with: '').set('New Section')
      within all("fieldset").last do
        click_link(add_question_text)
        find_field('Question Text', with: '').set(@grant.questions.first.text)
        find_field('Type of Response').select('Number')
      end
      click_button 'Save'
      expect(page).to have_text 'Submission Form successfully updated'
    end

    context 'paper_trail', versioning: true do
      scenario 'it tracks whodunnit' do
        find_field('Question Text', with: @grant.questions.first.text).set('Updated')
        click_button 'Save'
        expect(@grant.questions.first.versions.last.whodunnit).to be @admin.id
      end
    end
  end
end
