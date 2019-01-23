require 'rails_helper'

RSpec.describe Field, type: :model do
  it { is_expected.to respond_to(:label) }
  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:help_text) }
  it { is_expected.to respond_to(:placeholder) }

  let(:field) { FactoryBot.build(:field) }

  describe '#validations' do
    it 'validates a valid field' do
      expect(field).to be_valid
    end

    it 'validates a field without a label' do
      field.label = nil
      expect(field).not_to be_valid
      expect(field.errors).to include :label
    end

    it 'validates label length' do
      field.label = 'Why'
      expect(field).not_to be_valid
      expect(field.errors).to include :label
    end
  end
end
