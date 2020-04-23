require 'rails_helper'

RSpec.describe PaperTrail::CriteriaReviewVersion, type: :model, versioning: true do
  let(:grant)            { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:review)           { create(:review, submission: grant.submissions.first,
                                           reviewer: grant.reviewers.first,
                                           assigner: grant.administrators.first) }
  let(:criterion)        { review.grant.criteria.first }
  let(:criteria_review)  { create(:scored_criteria_review, criterion: criterion,
                                                           review: review) }

  context 'metadata' do
    it 'tracks review_id' do
      review.update(overall_impact_score: rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE))
      expect(criteria_review.versions.last.review_id).to eql review.id
    end
  end
end
