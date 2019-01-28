require 'rails_helper'

RSpec.describe Constraint, type: :model do
  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:value_type) }
  it { is_expected.to respond_to(:default) }

  let(:integer_constraint) { FactoryBot.build(:integer_constraint) }
  let(:string_constraint) { FactoryBot.build(:string_constraint) }

  describe '#validations' do
    it 'validates a valid constraint' do
      expect(integer_constraint).to be_valid
      expect(string_constraint).to be_valid
    end

    it 'requires a name' do
      string_constraint.name = nil
      expect(string_constraint).not_to be_valid
      expect(string_constraint.errors).to include(:name)
    end

    it 'requires a name to be more than 3 characters' do
      string_constraint.name = 'Why'
      expect(string_constraint).not_to be_valid
      expect(string_constraint.errors).to include(:name)
    end

    it 'requires value to be of default value_type' do
      integer_constraint.default = 'a string'
      expect(integer_constraint).not_to be_valid
      expect(integer_constraint.errors).to include(:default)
    end
  end
end
