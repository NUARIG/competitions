require 'rails_helper'

RSpec.describe PaperTrail::CriteriaReviewVersion, type: :model, versioning: true do
  before(:each) do
    @grant           = create(:open_grant_with_users_and_form_and_submission_and_reviewer)
    @reviewer        = @grant.reviewers.first
    @review          = create(:review, submission: @grant.submissions.first,
                                       reviewer: @reviewer,
                                       assigner: @grant.administrators.first)
    @criterion       = @review.grant.criteria.first
    @criteria_review = create(:scored_criteria_review, criterion: @criterion,
                                                       review: @review)
  end

  context 'metadata' do
    it 'tracks review_id' do
      expect(@criteria_review.versions.last.review_id).to eql @review.id
    end
  end
end
