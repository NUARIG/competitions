require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::ApplicantVersion, type: :model, versioning: true do
  before(:each) do
    @grant      = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @submission = @grant.submissions.first
    @applicant  = create(:grant_submission_applicant, submission: @submission, user: @submission.submitter)
  end

  context 'metadata' do
    it 'tracks grant_submission_submission_id' do
      expect(@applicant.versions.last.grant_submission_submission_id).to eql @submission.id
    end

    it 'tracks user_id' do
      expect(@applicant.versions.last.user_id).to eql @submission.submitter.id
    end
  end
end
