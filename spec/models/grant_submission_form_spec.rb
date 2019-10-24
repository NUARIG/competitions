require 'rails_helper'

RSpec.describe GrantSubmission::Form, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:submission_instructions) }
  it { is_expected.to respond_to(:created_id) }
  it { is_expected.to respond_to(:updated_id) }

  let(:form) { create(:grant_submission_form) }

  describe '#validations' do
    it 'validates a valid form' do
      expect(form).to be_valid
    end

    it 'requires a grant' do
      form.grant = nil
      expect(form).not_to be_valid
      expect(form.errors).to include(:grant)
    end

    it 'requires submission_instructions to be no longer than 3000 characters' do
      form.submission_instructions = Faker::Lorem.characters(number: 3001)
      expect(form).not_to be_valid
      expect(form.errors).to include(:submission_instructions)
      form.submission_instructions = Faker::Lorem.characters(number: 3000)
      expect(form).to be_valid
      expect(form.errors).not_to include(:submission_instructions)
    end
  end

  describe '#methods' do
    it 'is not destroyable?' do
      expect(form.destroyable?).to be false
    end
  end
end
