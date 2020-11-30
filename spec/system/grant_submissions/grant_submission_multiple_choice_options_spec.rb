require 'rails_helper'

RSpec.describe 'GrantSubmission::MultipleChoiceOptions', type: :system do
  def requires_option_text
    I18n.t('activerecord.errors.models.grant_submission/question.attributes.response_type.requires_option')
  end

  describe '#validations', js: true do
    before(:each) do
      @grant  = create(:draft_open_grant)
      @form   = @grant.form
      @admin  = @grant.administrators.first
      @option = @grant.questions.find_by(response_type: 'pick_one').multiple_choice_options.first

      login_as(@admin, scope: :saml_user)
      visit edit_grant_form_path(@grant, @form)
    end

    context 'edit' do
      scenario 'requires at least one option' do
        @grant.questions.where(response_type: 'pick_one').last.multiple_choice_options.count.times do
          accept_alert do
            find('.delete-option', match: :first).click
          end
        end
        click_button 'Save'
        expect(page).to have_text requires_option_text
        find('.add-option').click
        click_button 'Save'
        expect(page).to have_text 'Multiple Choice Option text cannot be empty'
      end

      scenario 'requires text' do
        @grant.questions.where(response_type: 'pick_one').last.multiple_choice_options.count.times do
          accept_alert do
            find('.delete-option', match: :first).click
          end
        end
        find('.add-option').click
        click_button 'Save'
        expect(page).to have_text 'Multiple Choice Option text cannot be empty'
      end

      context 'paper_trail', versioning: true do
        scenario 'it tracks whodunnit' do
          find_field(with: @option.text).set('Updated')
          click_button 'Save'
          expect(@option.versions.last.whodunnit).to be @admin.id
        end
      end
    end
  end
end
