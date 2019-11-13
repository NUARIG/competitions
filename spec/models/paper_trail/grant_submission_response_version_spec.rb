require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::ResponseVersion, type: :model, versioning: true do
  before(:each) do
    @grant    = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @response = @grant.submissions.first.responses.first
    @question = @response.question
  end

  context 'metadata' do
    it 'tracks grant_submission_question_id' do

      expect(@response.versions.last.grant_submission_question_id).to eql @question.id
    end
  end
end
