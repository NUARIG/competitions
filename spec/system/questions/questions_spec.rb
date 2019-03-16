# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @organization          = FactoryBot.create(:organization)
      @user                  = FactoryBot.create(:user, organization: @organization)
      @grant                 = FactoryBot.create(:grant, organization: @organization)
      @grant_user            = FactoryBot.create(:editor_grant_user, grant_id: @grant.id,
                                                                     user_id: @user.id)
      @question              = FactoryBot.create(:string_question, grant_id: @grant.id, required: false)
      @max_length_constraint = FactoryBot.create(:string_maximum_length_constraint_question, question_id: @question.id)
      @max_length_constraint = FactoryBot.create(:string_minimum_length_constraint_question, question_id: @question.id)
      login_as(@user)
    end

    context '#constraints' do
      scenario 'constraint requirement can be edited using grant edit' do
        visit edit_grant_path(@grant.id)
        page.uncheck "question-#{@question.id}-required"
        click_button 'Save and Complete'
        find(:id, "grant-#{@grant.id}-edit").click
        expect(page.find_by_id("question-#{@question.id}-required")).not_to be_checked
      end
    end
  end
end
