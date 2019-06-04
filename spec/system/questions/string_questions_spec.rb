# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'String Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      # move to a shared context - grant_setup
      # use let rather than instance variables
      @organization          = FactoryBot.create(:organization)
      @user                  = FactoryBot.create(:user, organization: @organization)
      @grant                 = FactoryBot.create(:grant, organization: @organization)
      @grant_user            = FactoryBot.create(:editor_grant_user, grant_id: @grant.id,
                                                                     user_id: @user.id)
      @question              = FactoryBot.create(:string_question, grant_id: @grant.id, required: false)
      @min_number_of_characters_constraint = FactoryBot.create(:string_minimum_number_of_characters_constraint_question, question_id: @question.id)
      @max_number_of_characters_constraint = FactoryBot.create(:string_maximum_number_of_characters_constraint_question, question_id: @question.id)
      login_as(@user)
    end

    context '#constraints' do
      scenario 'constraints can be edited', versioning: true do
        visit edit_grant_question_path(@grant, @question)
        expect(page).to have_field("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: @min_number_of_characters_constraint.value)
        fill_in("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '2')
        click_button 'Save'
        click_link('Edit', href: edit_grant_question_path(@grant, @question).to_s)
        expect(page).to have_field("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '2')
      end

      scenario 'minimum and maximum logic is enforced', versioning: true do
        visit edit_grant_question_path(@grant, @question)
        fill_in("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '200')
        fill_in("constraint-question-#{@max_number_of_characters_constraint.id}-value", with: '100')
        click_button 'Save'
        expect(page).to have_content 'Maximum number of characters must be less than the minimum.'
      end

      scenario 'values cannot exceed 255', versioning: true do
        visit edit_grant_question_path(@grant, @question)
        fill_in("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '256')
        click_button 'Save'
        expect(page).to have_content 'Number of characters must be less than 255 characters.'
        fill_in("constraint-question-#{@min_number_of_characters_constraint.id}-value", with: '2')
        fill_in("constraint-question-#{@max_number_of_characters_constraint.id}-value", with: '256')
        expect(page).to have_content 'Number of characters must be less than 255 characters.'
      end
    end
  end
end
