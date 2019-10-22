require 'rails_helper'

RSpec.describe GrantSubmission::Section, type: :model do
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:display_order) }

  let(:section) { create(:grant_submission_section) }

  describe '#validations' do
    it 'validates a valid section' do
      expect(section).to be_valid
    end

    it 'requires a form' do
      section.form = nil
      expect(section).not_to be_valid
      expect(section.errors).to include(:form)
    end

    it 'does not allow a title longer than 255 characters' do
      section.title = Faker::Lorem.characters(256)
      expect(section).not_to be_valid
      expect(section.errors).to include(:title)
      section.title = Faker::Lorem.characters(255)
      expect(section).to be_valid
    end
  end

  describe 'available' do
    it 'is available? when new' do
      expect(section.available?).to be true
    end

    it 'is not available? when parent form is not available' do
      allow_any_instance_of(GrantSubmission::Form).to receive(:available?).and_return(false)
      expect(section.available?).to be false
    end
  end
end
