require 'rails_helper'

RSpec.describe Constraint, type: :model do
  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:value_type) }
  it { is_expected.to respond_to(:default) }

  let(:integer_constraint) { FactoryBot.build(:integer_constraint) }
  let(:float_constraint) { FactoryBot.build(:float_constraint) }

  describe '#validations' do
    it 'validates a valid constraint' do
      expect(integer_constraint).to be_valid
      expect(float_constraint).to be_valid
    end

    it 'requires a name' do
      float_constraint.name = nil
      expect(float_constraint).not_to be_valid
      expect(float_constraint.errors).to include(:name)
    end

    it 'requires a name to be more than 3 characters' do
      float_constraint.name = 'Why'
      expect(float_constraint).not_to be_valid
      expect(float_constraint.errors).to include(:name)
    end

    it 'requires value to be of default value_type' do
      integer_constraint.default = 'a string'
      expect(integer_constraint).not_to be_valid
      expect(integer_constraint.errors).to include(:default)
    end

    it 'requires a float_constraint to have a float default' do
      float_constraint.default = 'a string'
      expect(float_constraint).not_to be_valid
      expect(float_constraint.errors).to include(:default)
      float_constraint.default = '10.5'
      expect(float_constraint).to be_valid
    end
  end
end
