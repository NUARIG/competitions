require 'rails_helper'

RSpec.describe ConstraintQuestion, type: :model do
  it { is_expected.to respond_to(:constraint) }
  it { is_expected.to respond_to(:question) }
  it { is_expected.to respond_to(:value) }

  let(:integer_constraint_question) { FactoryBot.build(:integer_constraint_question) }
  let(:float_constraint_question)   { FactoryBot.build(:float_constraint_question) }
  let(:string_constraint_question)  { FactoryBot.build(:sting_constraint_question) }

  describe '#validations' do
    it 'validates unique combination of constraint and question' do
      integer_constraint_question.save
      new_integer_constraint_question = ConstraintQuestion.new(constraint_id: integer_constraint_question.constraint_id, question_id: integer_constraint_question.question_id, value: 10)
      expect(new_integer_constraint_question).not_to be_valid
      expect(new_integer_constraint_question.errors.messages[:constraint_id]).to eql ['can only be constrained once.']
    end

    context 'integer_constraint_question' do
      it 'validates a valid integer constraint_question' do
        expect(integer_constraint_question).to be_valid
      end

      it 'requires a value to match constraint.value_type' do
        integer_constraint_question.value = 'a string'
        expect(integer_constraint_question).not_to be_valid
        expect(integer_constraint_question.errors).to include(:value)
      end
    end

    context 'float_constraint_question' do
      it 'validates a valid float_constraint_question' do
        expect(float_constraint_question).to be_valid
      end

      it 'requires a value to match constraint.value_type' do
        float_constraint_question.value = 'a string'
        expect(float_constraint_question).not_to be_valid
        expect(float_constraint_question.errors).to include(:value)
      end
    end
  end
end
