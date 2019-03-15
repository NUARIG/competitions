require 'rails_helper'

RSpec.describe Submission, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:project_title) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:composite_score_average) }
  it { is_expected.to respond_to(:final_impact_score_average) }
  it { is_expected.to respond_to(:award_amount) }

  let(:draft_submission) { FactoryBot.build(:draft_submission) }

  describe '#validations' do
    it 'validates a valid submission' do
      expect(draft_submission).to be_valid
    end

    context 'grant' do
      it 'requires a grant' do
        draft_submission.grant = nil
        expect(draft_submission).not_to be_valid
        expect(draft_submission.errors).to include :grant
      end
    end

    context 'user' do
      it 'requires a user' do
        draft_submission.user = nil
        expect(draft_submission).not_to be_valid
        expect(draft_submission.errors).to include :user
      end
    end

    context 'project_title' do
      it 'requires a project_title' do
        draft_submission.project_title = nil
        expect(draft_submission).not_to be_valid
        expect(draft_submission.errors).to include :project_title
      end
    end

    context 'state' do
      it 'requires a state' do
        draft_submission.state = nil
        expect(draft_submission).not_to be_valid
        expect(draft_submission.errors).to include :state
      end
    end

  end
end