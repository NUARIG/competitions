require 'rails_helper'

RSpec.describe Field, type: :model do
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:help_text) }
  it { is_expected.to respond_to(:placeholder) }

  let(:field) { FactoryBot.build(:field) }

  describe '#validations' do
    it 'validates a field without a name' do
      field.name = nil
      expect(field).not_to be_valid
      expect(field.errors).to include :name
    end

    it 'validates name length' do
      field.name = 'Why'
      expect(field).not_to be_valid
      expect(field.errors)
    end

    # pending
    it 'validates placeholder length'
  end

end
