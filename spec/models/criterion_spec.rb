require 'rails_helper'

RSpec.describe Criterion, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:is_mandatory) }
  it { is_expected.to respond_to(:show_comment_field) }
  it { is_expected.to respond_to(:criteria_reviews) }

  context '#validations' do
    let(:grant)     { create(:grant) }
    let(:criterion) { build(:criterion, grant: grant) }

    it 'validates a valid criterion' do
      expect(criterion).to be_valid
    end

    context '#name' do
      it 'requires a name' do
        criterion.name = nil
        expect(criterion).not_to be_valid
      end

      it 'requires a unique name per grant' do
        @other_criterion = create(:criterion, grant: grant)
        criterion.name = @other_criterion.name
        expect(criterion).not_to be_valid
      end
    end
  end
end
