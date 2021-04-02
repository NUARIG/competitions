require 'rails_helper'

RSpec.describe GrantSubmission::Applicant, type: :model do
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:role) }

  let(:submission) { create(:grant_submission_submission) }
  let(:applicant) { create(:grant_submission_applicant, submission: submission, user: submission.submitter) }

  describe '#validations' do
    it 'validates a valid section' do
      expect(applicant).to be_valid
    end

    it 'requires a submission' do
      applicant.submission = nil
      expect(applicant).not_to be_valid
      expect(applicant.errors).to include(:submission)
    end

    it 'requires a user' do
      applicant.user = nil
      expect(applicant).not_to be_valid
      expect(applicant.errors).to include(:user)
    end

    it 'requires a role' do
      applicant.role = nil
      expect(applicant).not_to be_valid
      expect(applicant.errors).to include(:role)
    end
  end

  describe '#validations' do
    it 'prevents deletion of last applicant' do
      applicant
      expect{applicant.destroy}.not_to change{submission.applicants.count}
      expect(applicant.errors).to include(:base)
      expect(applicant.errors[:base]).to include('This user\'s role cannot be deleted.')
    end
  end
end
