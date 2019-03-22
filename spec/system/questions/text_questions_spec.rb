# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Text Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      # move to a shared context - grant_setup
      # use let rather than instance variables
      @organization          = FactoryBot.create(:organization)
      @user                  = FactoryBot.create(:user, organization: @organization)
      @grant                 = FactoryBot.create(:grant, organization: @organization)
      @grant_user            = FactoryBot.create(:editor_grant_user, grant_id: @grant.id,
                                                                     user_id: @user.id)
      @question              = FactoryBot.create(:text_question, grant_id: @grant.id, required: false)
      @min_number_of_characters_constraint = FactoryBot.create(:text_minimum_number_of_characters_constraint_question, question_id: @question.id)
      @max_number_of_characters_constraint = FactoryBot.create(:text_maximum_number_of_characters_constraint_question, question_id: @question.id)
      login_as(@user)
    end

    context '#constraints' do
      scenario 'constraints can be edited', versioning: true do
        visit edit_grant_question_path(@grant.id, @question.id)
        expect(page).to have_field("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: @min_number_of_characters_constraint.value)
        fill_in("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '2')
        click_button 'Save'
        click_link('Edit', href: edit_grant_question_path(@grant.id, @question.id).to_s)
        expect(page).to have_field("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '2')
      end

      scenario 'minimum and maximum logic is enforced', versioning: true do
        visit edit_grant_question_path(@grant.id, @question.id)
        fill_in("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '2000')
        fill_in("constraint-question-#{@max_number_of_characters_constraint.id}-value", with: '1000')
        click_button 'Save'
        expect(page).to have_content 'Maximum number of characters must be less than the minimum.'
      end
    end
  end
end
