require 'rails_helper'

RSpec.describe GrantSubmission::Question, type: :model do
  it { is_expected.to respond_to(:section) }
  it { is_expected.to respond_to(:form) }
  it { is_expected.to respond_to(:text) }
  it { is_expected.to respond_to(:display_order) }
  it { is_expected.to respond_to(:is_mandatory) }
  it { is_expected.to respond_to(:instruction) }

  context 'short_answer question' do
    describe '#validations' do
      let(:question) { build(:grant_submission_question) }

      it 'validates a valid question' do
        expect(question).to be_valid
      end

      it 'requires a section' do
        question.section = nil
        expect(question).not_to be_valid
        expect(question.errors).to include(:section)
      end

      it 'requires a response_type' do
        question.section = nil
        expect(question).not_to be_valid
        expect(question.errors).to include(:section)
      end

      it 'requires a positive display_order' do
        question.display_order = -1
        expect(question).not_to be_valid
        expect(question.errors).to include(:display_order)
      end

      it 'requires response_type to be a valid response type' do
        question.response_type = Faker::Lorem.word
        expect(question).not_to be_valid
        expect(question.errors).to include(:response_type)
      end

      it 'requires instruction to be 4000 characters or less' do
        question.instruction = Faker::Lorem.characters(4001)
        expect(question).not_to be_valid
        expect(question.errors).to include(:instruction)
        question.instruction = Faker::Lorem.characters(4000)
        expect(question).to be_valid
      end

      it 'requires text' do
        question.text = ''
        expect(question).not_to be_valid
        expect(question.errors).to include(:text)
      end

      it 'requires text to be 4000 characters or less' do
        question.text = Faker::Lorem.characters(4001)
        expect(question).not_to be_valid
        expect(question.errors).to include(:text)
        question.text = Faker::Lorem.characters(4000)
        expect(question).to be_valid
      end

      it 'requires is_mandatory to be boolean value' do
        question.is_mandatory = nil
        expect(question).not_to be_valid
        expect(question.errors).to include(:is_mandatory)
      end
    end
  end

  context 'long_text question' do
    describe '#validations' do
      let(:question) { build(:long_text_question) }

      it 'validates a valid question' do
        expect(question).to be_valid
      end
    end
  end

  context 'number question' do
    describe '#validations' do
      let(:question) { build(:number_question) }

      it 'validates a valid question' do
        expect(question).to be_valid
      end
    end
  end

  context 'date question' do
    describe '#validations' do
      let(:question) { build(:date_question) }

      it 'validates a valid question' do
        expect(question).to be_valid
      end
    end
  end

  context 'multiple_choice_question' do
    describe '#validations' do
      let(:multiple_choice_question) { create(:multiple_choice_question_with_options) }

      it 'validates a valid question' do
        expect(multiple_choice_question).to be_valid
      end

      it 'requires at least one option' do
        multiple_choice_question.multiple_choice_options.delete_all
        expect(multiple_choice_question).not_to be_valid
        expect(multiple_choice_question.errors.messages[:response_type].to_s).to include('requires at least one option')
      end
    end
  end

  context 'available' do
    let(:question)  { build(:grant_submission_question) }

    it 'is not available if form is not available' do
      allow_any_instance_of(GrantSubmission::Form).to receive(:available?).and_return(false)
      expect(question.available?).to be true
    end

    it 'is available if form is available' do
      allow_any_instance_of(GrantSubmission::Form).to receive(:available?).and_return(true)
      expect(question.available?).to be true
    end
  end
end
