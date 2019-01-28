require 'rails_helper'

RSpec.describe ConstraintField, type: :model do
  it { is_expected.to respond_to(:constraint) }
  it { is_expected.to respond_to(:field) }
  it { is_expected.to respond_to(:value) }

  let(:integer_constraint_field) { FactoryBot.build(:integer_constraint_field) }
  let(:float_constraint_field) { FactoryBot.build(:float_constraint_field) }

  describe '#validations' do
    context 'integer_constraint_field' do
      it 'validates a valid integer constraint_field' do
        expect(integer_constraint_field).to be_valid
      end

      it 'requires a value to match constraint.value_type' do
        integer_constraint_field.value = 'a string'
        expect(integer_constraint_field).not_to be_valid
        expect(integer_constraint_field.errors).to include(:value)
      end
    end

    context 'float_constraint_field' do
      it 'validates a valid float_constraint_field' do
        expect(float_constraint_field).to be_valid
      end

      it 'requires a value to match constraint.value_type' do
        float_constraint_field.value = 'a string'
        expect(float_constraint_field).not_to be_valid
        expect(float_constraint_field.errors).to include(:value)
      end
    end
  end
end
