require 'rails_helper'

RSpec.describe GrantSubmission::Permission, type: :model do
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:user) }

  let(:submission) { create(:grant_submission_submission) }
  let(:permission) { create(:grant_submission_permission, submission: submission, user: submission.submitter) }

  describe '#validations' do
    it 'validates a valid submission permission' do
      expect(permission).to be_valid
    end

    it 'requires a submission' do
      permission.submission = nil
      expect(permission).not_to be_valid
      expect(permission.errors).to include(:submission)
    end

    it 'requires a user' do
      permission.user = nil
      expect(permission).not_to be_valid
      expect(permission.errors).to include(:user)
    end

  end
end
