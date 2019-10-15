require 'rails_helper'

RSpec.describe 'GrantSubmission::Sections', type: :system do
  describe 'Grant Edit section', js: true do
    before(:each) do
      @grant = create(:draft_grant)
      @form  = @grant.form

      login_as(@grant.editors.first)
      visit edit_grant_form_path(@grant, @form)
    end

    scenario 'it requires a title' do
      click_link 'Add a Section'
      find_field('Title', with: '').set('')
      click_button 'Save'
      expect(page).not_to have_text 'Submission Form successfully update'
      expect(page).to have_text 'Section Title is required.'
    end

    scenario 'it requires a unique title' do
      click_link 'Add a Section'
      find_field('Title', with: '').set(@form.sections.first.title)
      click_button 'Save'
      expect(page).not_to have_text 'Submission Form successfully update'
      expect(page).to have_text 'Section Title must be unique to this competition.'
    end
  end
end
