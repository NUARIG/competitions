require 'rails_helper'

RSpec.describe Field, type: :model do
  it { is_expected.to respond_to(:label) }
  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:help_text) }
  it { is_expected.to respond_to(:placeholder) }

  let(:integer_field) { FactoryBot.build(:integer_field) }

  describe '#validations' do
    it 'validates a valid field' do
      expect(integer_field).to be_valid
    end

    it 'validates a field without a label' do
      integer_field.label = nil
      expect(integer_field).not_to be_valid
      expect(integer_field.errors).to include :label
    end

    it 'validates label length' do
      integer_field.label = 'Why'
      expect(integer_field).not_to be_valid
      expect(integer_field.errors).to include :label
    end
  end
end
