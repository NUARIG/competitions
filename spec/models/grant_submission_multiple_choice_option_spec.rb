require 'rails_helper'

RSpec.describe GrantSubmission::MultipleChoiceOption, type: :model do
  it { is_expected.to respond_to(:question) }
  it { is_expected.to respond_to(:text) }

  let(:multiple_choice_option) { create(:multiple_choice_option) }

  describe '#validations' do
    it 'validates a valid multiple choice option' do
      expect(multiple_choice_option).to be_valid
    end

    it 'requires a question' do
      multiple_choice_option.question = nil
      expect(multiple_choice_option).not_to be_valid
      expect(multiple_choice_option.errors).to include(:question)
    end

    it 'requires text' do
      multiple_choice_option.text = nil
      expect(multiple_choice_option).not_to be_valid
      expect(multiple_choice_option.errors).to include(:text)
    end

    it 'requires text to be less than 255 characters' do
      multiple_choice_option.text = Faker::Lorem.characters(256)
      expect(multiple_choice_option).not_to be_valid
      expect(multiple_choice_option.errors).to include(:text)
      multiple_choice_option.text = Faker::Lorem.characters(255)
      expect(multiple_choice_option).to be_valid
    end
  end

  describe '#available?' do
    it 'is available? when new' do
      expect(multiple_choice_option.available?).to be true
    end

    it 'is not available? when parent form is not available' do
      allow_any_instance_of(GrantSubmission::Form).to receive(:available?).and_return(false)
      expect(multiple_choice_option.available?).to be false
    end
  end
end
