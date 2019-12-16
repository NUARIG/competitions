require 'rails_helper'

RSpec.describe PaperTrail::ReviewVersion, type: :model, versioning: true  do
  before(:each) do
    @grant          = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @reviewer       = @grant.reviewers.first
    @review         = create(:review, submission: @grant.submissions.first,
                                      assigner:   @grant.editors.first,
                                      reviewer:   @reviewer)
  end

  context 'metadata' do
    it 'tracks grant_id' do
      expect(PaperTrail::ReviewVersion.last.grant_id).to eql @grant.id
    end

    it 'tracks reviewer_id', versioning: true do
      expect(PaperTrail::ReviewVersion.last.reviewer_id).to eql @reviewer.id
    end
  end
end
