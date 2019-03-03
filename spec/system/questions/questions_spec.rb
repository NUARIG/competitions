require 'rails_helper'

RSpec.describe 'Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      # move to a shared context - grant_setup
      # use let rather than instance variables?
      @organization          = FactoryBot.create(:organization)
      @user                  = FactoryBot.create(:user, organization: @organization, organization_role: 'editor')
      @grant                 = FactoryBot.create(:grant, organization: @organization)
      @question              = FactoryBot.create(:string_question, grant_id: @grant.id, required: false)
      @max_length_constraint = FactoryBot.create(:string_maximum_length_constraint_question, question_id: @question.id)
      @max_length_constraint = FactoryBot.create(:string_minimum_length_constraint_question, question_id: @question.id)
      login_as(@user)
    end

    scenario 'versioning tracks whodunnit', versioning: true do
      visit edit_grant_question_path(@grant.id, @question.id)
      fill_in('question_name', with: 'New Question')
      click_button 'Save'
      expect(@question.versions.last.whodunnit).to eql(@user.id)
    end

    context "#constraints" do
      scenario 'constraint requirement can be edited', versioning: true do
      end
    end
  end
end
