require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::SubmissionApplicantVersion, type: :model, versioning: true do
  before(:each) do
    @grant                  = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @submission             = @grant.submissions.first
    @applicant              = create(:saml_user)
    @submission_applicant   = create(:grant_submission_submission_applicant, submission: @submission,
                                                                             applicant: @applicant)
  end

  context 'metadata' do
    it 'tracks grant_submission_submission_id' do
      expect(@submission_applicant.versions.last.grant_submission_submission_id).to eql @submission.id
    end

    it 'tracks applicant_id' do
      expect(@submission_applicant.versions.last.applicant_id).to eql @applicant.id
    end
  end
end
