# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CriteriaReview, type: :model do

  it_should_behave_like "WithScoring"

  it { is_expected.to respond_to(:criterion) }
  it { is_expected.to respond_to(:review) }
  it { is_expected.to respond_to(:score) }
  it { is_expected.to respond_to(:comment) }
  it { is_expected.to respond_to(:submission) }
  it { is_expected.to respond_to(:grant) }

  context 'validations' do
    let(:grant)  { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:review) { create(:review, submission: grant.submissions.first,
                                   assigner: grant.editors.first,
                                   reviewer: grant.reviewers.first) }

    before(:each) do
      @criteria_review = build(:scored_criteria_review, criterion: grant.criteria.first,
                                                        review:    review)
    end

    it 'validates a valid criteria_review' do
      expect(@criteria_review).to be_valid
    end

    context '#uniqueness' do
      it 'may only have one entry per criterion' do
        @scored_criteria_review = create(:scored_criteria_review, criterion: grant.criteria.first,
                                                                  review:    review)
        expect(@criteria_review).not_to be_valid
      end
    end

    context '#score' do
      it 'requires score to be minimum or higher' do
        @criteria_review.score = Review::MINIMUM_ALLOWED_SCORE - 1
        expect(@criteria_review).not_to be_valid
        expect(@criteria_review.errors).to include(:score)
        @criteria_review.score = Review::MINIMUM_ALLOWED_SCORE
        expect(@criteria_review).to be_valid
      end

      it 'requires score to be maximum or lower' do
        @criteria_review.score = Review::MAXIMUM_ALLOWED_SCORE + 1
        expect(@criteria_review).not_to be_valid
        expect(@criteria_review.errors).to include(:score)
        @criteria_review.score = Review::MAXIMUM_ALLOWED_SCORE
        expect(@criteria_review).to be_valid
      end

      it 'requires a score if criterion is mandatory' do
        @criteria_review.criterion.is_mandatory = true
        @criteria_review.score = nil
        expect(@criteria_review).not_to be_valid
        expect(@criteria_review.errors.messages[:base]).to eq ["'#{@criteria_review.criterion.name}' must be scored."]
      end

      it 'requires score to be from the correct grant' do
        @other_grant    = create(:grant)
        @other_criteria = create(:criterion, grant: @other_grant)
        @criteria_review.update_attribute(:criterion, @other_criteria)
        expect(@criteria_review).not_to be_valid
        expect(@criteria_review.errors.messages[:base]).to eq ["'#{@criteria_review.criterion.name} (ID: #{@criteria_review.criterion.id}) is not a valid criterion for this grant."]
      end
    end

    context '#comment' do
      it 'rejects a comment if criteria\'s comment is not shown' do
        expect(@criteria_review).to be_valid
        @criteria_review.criterion.show_comment_field = false
        @criteria_review.comment = Faker::Lorem.sentence
        expect(@criteria_review).not_to be_valid
        expect(@criteria_review.errors.messages[:base]).to eq ["Comments are not allowed on '#{@criteria_review.criterion.name}'."]
      end
    end
  end
end
