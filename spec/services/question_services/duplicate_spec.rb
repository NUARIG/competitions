# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionServices do
  describe 'Duplicate' do
    before(:each) do
      @question  = FactoryBot.create(:string_question, :with_constraints)
      @new_grant = FactoryBot.create(:grant)
    end

    it 'duplicates a question and assigns it to a grant' do
      expect(@new_grant.questions.count).to be(0)
      expect do
        QuestionServices::Duplicate.call(new_grant: @new_grant, question: @question)
      end.to change{@new_grant.questions.count}.by(1).and change{ConstraintQuestion.count}.by (@question.constraints.count)
    end
  end
end
