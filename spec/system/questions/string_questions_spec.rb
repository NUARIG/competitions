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
      @min_length_constraint = FactoryBot.create(:string_minimum_length_constraint_question, question_id: @question.id)
      @max_length_constraint = FactoryBot.create(:string_maximum_length_constraint_question, question_id: @question.id)
      login_as(@user)
    end

    context '#constraints' do
      scenario 'constraints can be edited', versioning: true do
        visit edit_grant_question_path(@grant.id, @question.id)
        expect(page).to have_field("constraint-question-#{@min_length_constraint.id}-value", with: @min_length_constraint.value)
        fill_in("constraint-question-#{@min_length_constraint.id}-value", with: '2')
        click_button 'Save'
        click_link('Edit', href: edit_grant_question_path(@grant.id, @question.id).to_s)
        expect(page).to have_field("constraint-question-#{@min_length_constraint.id}-value", with: '2')
      end

      scenario 'minimum and maximum logic is enforced', versioning: true do
        visit edit_grant_question_path(@grant.id, @question.id)
        fill_in("constraint-question-#{@min_length_constraint.id}-value", with: '200')
        fill_in("constraint-question-#{@max_length_constraint.id}-value", with: '100')
        click_button 'Save'
        expect(page).to have_content 'Maximum length must be less than the minimum.'
      end

      scenario 'values cannot exceed 255', versioning: true do
        visit edit_grant_question_path(@grant.id, @question.id)
        fill_in("constraint-question-#{@min_length_constraint.id}-value", with: '256')
        click_button 'Save'
        expect(page).to have_content 'Lengths must be less than 255 characters.'
        fill_in("constraint-question-#{@min_length_constraint.id}-value", with: '2')
        fill_in("constraint-question-#{@max_length_constraint.id}-value", with: '256')
        expect(page).to have_content 'Lengths must be less than 255 characters.'
      end
    end
  end
end
