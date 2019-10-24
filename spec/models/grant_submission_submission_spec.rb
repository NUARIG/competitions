require 'rails_helper'

RSpec.describe GrantSubmission::Submission, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:form) }
  it { is_expected.to respond_to(:applicant) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:reviews) }
  it { is_expected.to respond_to(:reviewers) }
  it { is_expected.to respond_to(:criteria_reviews) }
  it { is_expected.to respond_to(:reviews_count) }

  let(:submission) { build(:submission_with_responses) }

  describe '#validations' do
    it 'validates a valid submission' do
      expect(submission).to be_valid
    end

    it 'requires a grant' do
      submission.grant = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:grant)
    end

    it 'requires a form' do
      submission.form = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:form)
    end

    it 'requires an applicant' do
      submission.applicant = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:applicant)
    end

    it 'requires a title' do
      submission.title = ''
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:title)
    end
  end
end
