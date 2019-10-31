require 'rails_helper'

RSpec.describe 'GrantSubmission::MultipleChoiceOptions', type: :system do
  def requires_option_text
    I18n.t('activerecord.errors.models.grant_submission/question.attributes.response_type.requires_option')
  end

  describe '#validations', js: true do
    before(:each) do
      @grant = create(:draft_open_grant)
      @form  = @grant.form

      login_as(@grant.editors.first)
      visit edit_grant_form_path(@grant, @form)
    end

    context 'edit' do
      scenario 'requires at least one option' do
        @grant.questions.where(response_type: 'pick_one').last.multiple_choice_options.count.times do
          find('.delete-option', match: :first).click
        end
        click_button 'Save'
        expect(page).to have_text requires_option_text
        find('.add-option').click
        click_button 'Save'
        expect(page).to have_text 'Multiple Choice Option text cannot be empty'
      end

      scenario 'requires text' do
        @grant.questions.where(response_type: 'pick_one').last.multiple_choice_options.count.times do
          find('.delete-option', match: :first).click
        end
        find('.add-option').click
        click_button 'Save'
        expect(page).to have_text 'Multiple Choice Option text cannot be empty'
      end
    end
  end
end
