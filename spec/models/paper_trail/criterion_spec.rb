require 'rails_helper'

RSpec.describe PaperTrail::CriterionVersion, type: :model, versioning: true do
  before(:each) do
    @grant           = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @reviewer        = @grant.reviewers.first
    @review          = create(:review, submission: @grant.submissions.first,
                                       reviewer: @reviewer,
                                       assigner: @grant.administrators.first)
    @criterion       = @review.grant.criteria.first
  end

  context 'metadata' do
    it 'tracks grant_id' do
      expect(@criterion.versions.last.grant_id).to eql @grant.id
    end
  end
end
