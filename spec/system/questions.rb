require 'rails_helper'

RSpec.describe 'Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @user                  = FactoryBot.create(:user)
      @grant                 = FactoryBot.create(:grant)
      @question              = FactoryBot.create(:string_question, grant_id: @grant.id, required: false)
      @min_length_constraint = FactoryBot.create(:string_minimum_length_constraint_question, question_id: @question.id)
      @min_length_constraint = FactoryBot.create(:string_maximum_length_constraint_question, question_id: @question.id)

      login_as(@user)
    end

    scenario 'edit question through grant' do
      visit edit_grant_path(@grant.id)
      click_link("Edit", href: "#{edit_grant_question_path(@grant.id, @question.id)}")
      sleep 10
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
