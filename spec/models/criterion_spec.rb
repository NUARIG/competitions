require 'rails_helper'

RSpec.describe Criterion, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:is_mandatory) }
  it { is_expected.to respond_to(:show_comment_field) }
  it { is_expected.to respond_to(:criteria_reviews) }

  context '#validations' do
    let(:grant)       { create(:published_open_grant_with_users, :with_reviewer) }
    let(:criterion)   { build(:criterion, grant: grant) }
    let(:submission)  { create(:submission_with_responses, grant: grant) }
    
    let(:submitted_review)  { create(:submitted_scored_review_with_scored_mandatory_criteria_review,
                                        submission: submission,
                                        reviewer: grant.reviewers.first,
                                        assigner: grant.admins.first,
                                        overall_impact_score: 5) }

    it 'validates a valid criterion' do
      expect(criterion).to be_valid
    end

    context '#grant' do
      it 'requires a grant' do
        criterion.grant = nil
        expect(criterion).not_to be_valid
      end
    end

    context '#name' do
      it 'requires a name' do
        criterion.name = nil
        expect(criterion).not_to be_valid
      end

      it 'requires a unique name per grant' do
        @other_criterion = create(:criterion, grant: grant)
        criterion.name = @other_criterion.name
        expect(criterion).not_to be_valid
      end
    end

    context '#with_submitted_reviews' do
      it 'is not valid when there is a submitted review' do
        submitted_review.touch
        expect(criterion).not_to be_valid
        expect(criterion.errors.full_messages).to include I18n.t('activerecord.errors.models.criterion.may_not_change_criterion_after_reviews_submitted')
      end
    end
  end
end
