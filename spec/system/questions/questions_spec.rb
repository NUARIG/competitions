require 'rails_helper'

RSpec.describe 'Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @organization = FactoryBot.create(:organization)
      @user         = FactoryBot.create(:user, organization: @organization, organization_role: 'editor')
      @grant        = FactoryBot.create(:grant, organization: @organization)
      @question     = FactoryBot.create(:string_question, grant_id: @grant.id, required: false)

      login_as(@user)
    end

    scenario 'edit question through grant' do
      visit edit_grant_path(@grant.id)
      click_link("Edit", href: "#{edit_grant_question_path(@grant.id, @question.id)}")
      expect(page).to have_field('question_name', with: @question.name)
      fill_in('question_name', with: 'New Question')
      click_button 'Save'
      expect(page).to have_current_path(edit_grant_path(@grant.id))
      expect(page).to have_selector(:id, "question-#{@question.id}-name", text: 'New Question')
    end

    scenario 'versioning tracks whodunnit', versioning: true do
      visit edit_grant_question_path(@grant.id, @question.id)
      fill_in('question_name', with: 'New Question')
      click_button 'Save'
      expect(@question.versions.last.whodunnit).to eql(@user.id)
    end
  end
end
