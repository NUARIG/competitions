require 'rails_helper'

RSpec.describe Review, type: :model do

  it_should_behave_like "WithScoring"

  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:assigner) }
  it { is_expected.to respond_to(:reviewer) }
  it { is_expected.to respond_to(:overall_impact_score) }
  it { is_expected.to respond_to(:overall_impact_comment) }
  it { is_expected.to respond_to(:reminded_at) }

  let(:grant)          { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
  let(:new_reviewer)   { create(:grant_reviewer, grant: grant)}
  let(:submission)     { grant.submissions.first }
  let(:assigner)       { grant.administrators.first }
  let(:review)         { build(:review, assigner: assigner,
                                        reviewer: grant.grant_reviewers.first.reviewer,
                                        submission: submission) }
  let(:invalid_review) { build(:review, assigner: assigner,
                                        reviewer: grant.grant_reviewers.first.reviewer,
                                        submission: submission) }
  let(:system_admin)   { create(:system_admin_saml_user) }
  let(:invalid_user)   { create(:saml_user) }

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

      it 'prevents a reviewer from being assigned the same review twice' do
        review.save
        expect(invalid_review).not_to be_valid
      end

      it 'prevents a draft submission from being reviewed' do
        submission.update_attribute(:state, 'draft')
        expect(review).not_to be_valid
        expect(review.errors).to include(:submission)
      end

      it 'prevents a review from being submitted after grant review close date' do
        grant.update(publish_date: 6.days.ago, submission_open_date: 5.days.ago, submission_close_date: 4.days.ago, review_open_date: 3.days.ago, review_close_date: 2.days.ago)
        expect(review).not_to be_valid
        expect(review.errors.messages[:base]).to include I18n.t('activerecord.errors.models.review.attributes.base.may_not_review_after_close_date', review_close_date: grant.review_close_date)
      end
    end

    describe '#update' do
      it 'requires an overall score' do
        review.update(overall_impact_score: nil)
        expect(review).not_to be_valid
        expect(review.errors).to include(:overall_impact_score)
      end

      it 'requires an overall score to be less than or equal to Review::MAXIMUM_ALLOWED_SCORE' do
        review.save
        review.overall_impact_score = Review::MAXIMUM_ALLOWED_SCORE + 1
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

      it 'prevents an update from being submitted after grant review close date' do
        review.save
        grant.update(publish_date: 6.days.ago, submission_open_date: 5.days.ago, submission_close_date: 4.days.ago, review_open_date: 3.days.ago, review_close_date: 2.days.ago)
        review.update(overall_impact_score: rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE))
        review.reload
        expect(review).not_to be_valid
        expect(review.errors.messages[:base]).to include I18n.t('activerecord.errors.models.review.attributes.base.may_not_review_after_close_date', review_close_date: grant.review_close_date)
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


  describe 'scope' do
    let(:reviewer1) { create(:grant_reviewer, grant: grant) }
    let(:reviewer2) { create(:grant_reviewer, grant: grant) }
    let(:reviewer3) { create(:grant_reviewer, grant: grant) }
    let(:reviewer4) { create(:grant_reviewer, grant: grant) }

    before(:each) do
      @completed           = create(:scored_review_with_scored_mandatory_criteria_review,
                                                        submission: submission,
                                                        assigner: assigner,
                                                        reviewer: reviewer1.reviewer)
      @incomplete          = create(:incomplete_review, submission: submission,
                                                        assigner: assigner,
                                                        reviewer: reviewer2.reviewer)
      @reminded_a_day_ago  = create(:reminded_review, submission: submission,
                                                        assigner: assigner,
                                                        reviewer: reviewer3.reviewer)
      @reminded_a_week_ago = create(:incomplete_review, submission: submission,
                                                        assigner: assigner,
                                                        reviewer: reviewer4.reviewer,
                                                        reminded_at: 2.weeks.ago)
    end

    context 'incomplete' do
      it 'returns only incomplete reviews' do
        incomplete_reviews = Review.by_grant(grant).incomplete
        expect(incomplete_reviews.count).to eql 3
        expect(incomplete_reviews).not_to include @completed_review
      end
    end

    context 'may_be_reminded' do
      pending 'returns un-remined reviews and reviews reminded more than a week ago' do
        fail 'Not implemented -- see app/models/review.rb:59'
        reviews_to_be_reminded = Review.by_grant(grant).may_be_reminded
        expect(reviews_to_be_reminded.count).to eql 2
        expect(reviews_to_be_reminded).to include @incomplete
        expect(reviews_to_be_reminded).to include @reminded_a_week_ago
        expect(reviews_to_be_reminded).not_to include @reminded_a_day_ago
      end
    end
  end

  describe 'methods' do
    context 'review_period_closed?' do
      it 'returns false when review_close_date is in the future' do
        expect(review.review_period_closed?).to be false
      end

      it 'returns true when review_close_date has passed' do
        allow_any_instance_of(Grant).to receive(:review_close_date).and_return(1.minute.ago)
        expect(review.review_period_closed?).to be true
      end
    end
  end
end
