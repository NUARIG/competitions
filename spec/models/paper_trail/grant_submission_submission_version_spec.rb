require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::SubmissionVersion, type: :model, versioning: true do
  before(:each) do
    @grant      = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @submission = @grant.submissions.first
    @submitter  = @submission.submitter
  end

  context 'metadata' do
    it 'tracks grant_id' do
      expect(@submission.versions.last.grant_id).to eql @grant.id
    end

    it 'tracks submitter_id' do
      expect(@submission.versions.last.submitter_id).to eql @submitter.id
    end
  end
end
