require 'rails_helper'

RSpec.describe Submission, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:project_title) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:composite_score_average) }
  it { is_expected.to respond_to(:final_impact_score_average) }
  it { is_expected.to respond_to(:award_amount) }

  let(:submission) { build(:submission) }
  let(:submission_for_open_grant) { create(:draft_submission_with_complete_open_grant) }
  let(:submission_for_closed_grant) { create(:draft_submission_with_complete_closed_grant) }

  describe '#validations' do
    it 'validates a valid submission' do
      expect(submission).to be_valid
    end

    context 'grant' do
      it 'requires a grant' do
        submission.grant = nil
        expect(submission).not_to be_valid
        expect(submission.errors).to include :grant
      end
    end

    context 'user' do
      it 'requires a user' do
        submission.user = nil
        expect(submission).not_to be_valid
        expect(submission.errors).to include :user
      end
    end

    context 'project_title' do
      it 'requires a project_title' do
        submission.project_title = nil
        expect(submission).not_to be_valid
        expect(submission.errors).to include :project_title
      end
    end

    context 'state' do
      it 'requires a state' do
        submission.state = nil
        expect(submission).not_to be_valid
        expect(submission.errors).to include :state
      end
    end

    context 'dates' do
      let(:submission_for_closed_grant) { FactoryBot.build(:submission_with_complete_closed_grant) }

      it 'rejects a submission for a closed grant' do
        expect(submission_for_closed_grant).not_to be_valid
      end
    end

  end
end