# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Questions', type: :system do
  describe 'Edit', js: true do
    before(:each) do
      @organization          = FactoryBot.create(:organization)
      @user                  = FactoryBot.create(:user, organization: @organization, organization_role: 'editor')
      @grant                 = FactoryBot.create(:grant, organization: @organization)
      @question              = FactoryBot.create(:string_question, grant_id: @grant.id, required: false)
      @max_length_constraint = FactoryBot.create(:string_maximum_length_constraint_question, question_id: @question.id)
      @max_length_constraint = FactoryBot.create(:string_minimum_length_constraint_question, question_id: @question.id)
      login_as(@user)
    end
  end
end
