require 'rails_helper'

RSpec.describe Review, type: :model do

  it_should_behave_like "WithScoring"

  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:assigner) }
  it { is_expected.to respond_to(:reviewer) }
  it { is_expected.to respond_to(:overall_impact_score) }
  it { is_expected.to respond_to(:overall_impact_comment) }

  let(:grant)          { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:new_reviewer)   { create(:grant_reviewer, grant: grant)}
  let(:review)         { build(:review, assigner: grant.administrators.first,
                                        reviewer: grant.grant_reviewers.first.reviewer,
                                        submission: grant.submissions.first) }
  let(:invalid_review) { build(:review, assigner: grant.administrators.first,
                                        reviewer: grant.grant_reviewers.first.reviewer,
                                        submission: grant.submissions.first) }
  let(:system_admin)   { create(:system_admin_user) }
  let(:invalid_user)   { create(:user) }

  let(:scored_review_with_criteria_reviews) { create(:scored_review_with_scored_mandatory_criteria_review, assigner: grant.administrators.first,
                                                                                                           submission: grant.submissions.first,
                                                                                                           reviewer: grant.reviewers.first)}

  describe 'validations' do
    context '#new' do
      it 'validates a valid review' do
        expect(review).to be_valid
      end

      it 'requires reviewer to be a grant reviewer' do
        review.reviewer = invalid_user
        expect(review).not_to be_valid
      end

      it 'requires assigner to have grant permission' do
        review.assigner = invalid_user
        expect(review).not_to be_valid
      end

      it 'disallows viewer to assign a review' do
        review.assigner = grant.grant_permissions.role_viewer.first.user
        expect(review).not_to be_valid
      end

      it 'allows system_admin to assign a review' do
        review.assigner = system_admin
        expect(review).to be_valid
      end

      it 'requires reviewer to not be the applicant' do
        review.reviewer = grant.submissions.first.applicant
        expect(review).not_to be_valid
      end

      it 'prevents a reviewer from being assigned twice' do
        review.save
        expect(invalid_review).not_to be_valid
      end
    end

    describe '#update' do
      it 'requires an overall score' do
        review.update(overall_impact_score: nil)
        expect(review).not_to be_valid
        expect(review.errors).to include(:overall_impact_score)
      end

      it 'requires an overall score to be less than or equal to Review::MAXIMUM_ALLOWED_SCORE' do
        review.update(overall_impact_score: Review::MAXIMUM_ALLOWED_SCORE + 1)
        expect(review).not_to be_valid
        expect(review.errors).to include(:overall_impact_score)
        review.update(overall_impact_score: Review::MAXIMUM_ALLOWED_SCORE)
        expect(review).to be_valid
      end

      it 'requires an overall score to be greater than or equal to Review::MINIMUM_ALLOWED_SCORE' do
        review.update(overall_impact_score: Review::MINIMUM_ALLOWED_SCORE - 1)
        expect(review).not_to be_valid
        expect(review.errors).to include(:overall_impact_score)
        review.overall_impact_score = (Review::MINIMUM_ALLOWED_SCORE)
        expect(review).to be_valid
      end

      it 'prevents a change in reviewer' do
        review.save
        review.update(reviewer: new_reviewer.reviewer)
        expect(review.errors[:reviewer]).to include(I18n.t('activerecord.errors.models.review.attributes.reviewer.may_not_be_reassigned'))
      end
    end

    describe '#scored criteria review' do
      it 'calculates a criterion average score' do
        scores = scored_review_with_criteria_reviews.criteria.pluck(:score)
        expect(scored_review_with_criteria_reviews.composite_score).to eql( (scores.sum.to_f / scores.count).round(2))
      end

      it 'includes non-mandatory scores in criterion average score' do
        scored_review_with_criteria_reviews.criteria.first.update_attributes(is_mandatory: false)
        scores = scored_review_with_criteria_reviews.criteria.pluck(:score)
        expect(scored_review_with_criteria_reviews.composite_score).to eql( (scores.sum.to_f / scores.count).round(2))
      end

      it 'does not include unscored scores in criterion average score' do
        review = scored_review_with_criteria_reviews
        expect do
          updated_criterion = review.criteria.where(is_mandatory: true).first
          updated_criterion.update_attribute(:is_mandatory, false)
          CriteriaReview.find_by(review: review, criterion: updated_criterion).update_attribute(:score, nil)
        end.to (change{review.scored_criteria_scores.count}.by(-1))
      end
    end
  end
end
