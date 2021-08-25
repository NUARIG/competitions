require 'rails_helper'

RSpec.describe GrantSubmission::SubmissionApplicant, type: :model do
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:applicant) }

  let(:submission)                { create(:grant_submission_submission) }
  let(:submission_applicant)      { create(:grant_submission_submission_applicant, submission: submission, applicant: submission.submitter) }

  let(:new_applicant)             { create(:saml_user) }
  let(:new_submission_applicant)  { build(:grant_submission_submission_applicant, submission: submission, applicant: new_applicant) }

  describe '#validations' do
    it 'validates a valid submission applicant' do
      expect(new_submission_applicant).to be_valid
    end

    it 'requires a submission' do
      submission_applicant.submission = nil
      expect(submission_applicant).not_to be_valid
      expect(submission_applicant.errors).to include(:submission)
    end

    it 'requires an applicant' do
      submission_applicant.applicant = nil
      expect(submission_applicant).not_to be_valid
      expect(submission_applicant.errors).to include(:applicant)
    end

    it 'requires the applicant is not already on submission' do
      expect(submission_applicant).not_to be_valid
    end
  end
end
