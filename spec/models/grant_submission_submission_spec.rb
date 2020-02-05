require 'rails_helper'

RSpec.describe GrantSubmission::Submission, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:form) }
  it { is_expected.to respond_to(:applicant) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:reviews) }
  it { is_expected.to respond_to(:reviewers) }
  it { is_expected.to respond_to(:criteria_reviews) }
  it { is_expected.to respond_to(:reviews_count) }

  let(:submission) { build(:submission_with_responses) }

  describe '#validations' do
    it 'validates a valid submission' do
      expect(submission).to be_valid
    end

    it 'requires a grant' do
      submission.grant = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:grant)
    end

    it 'requires a form' do
      submission.form = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:form)
    end

    it 'requires an applicant' do
      submission.applicant = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:applicant)
    end

    it 'requires a title' do
      submission.title = ''
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:title)
    end
  end

  describe 'score related methods' do
    let(:grant)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:grant_admin)       { grant.grant_permissions.role_admin.first.user }
    let(:grant_reviewer)    { create(:grant_reviewer, grant: grant) }
    let(:reviewer1)         { grant.reviewers.first }
    let(:reviewer2)         { grant_reviewer.reviewer }
    let(:grant_submission)  { grant.submissions.first }
    let(:scored_review)     { create(:scored_review_with_scored_mandatory_criteria_review, submission: grant_submission,
                                                                                           assigner: grant_admin,
                                                                                           reviewer: reviewer1) }
    let(:incomplete_review) { create(:incomplete_review, submission: grant_submission,
                                                         assigner: grant_admin,
                                                         reviewer: reviewer2) }
    let(:add_score)         { create(:scored_criteria_review, review: incomplete_review,
                                                              criterion: grant.criteria.first)}

    before(:each) do
      reviews = [scored_review, incomplete_review]
    end

    context '#overall_impact_scores' do
      it 'returns overall_impact_score for scored and incomplete reviews' do
        expect(grant_submission.overall_impact_scores.length).to be 2
        expect(grant_submission.overall_impact_scores).to include scored_review.overall_impact_score
        expect(grant_submission.overall_impact_scores).to include nil
      end
    end

    context '#all_scored_criteria' do
      it 'returns only scored criteria scores' do
        expect(grant_submission.all_scored_criteria).not_to include nil
        expect(grant_submission.all_scored_criteria.length).to be scored_review.criteria.length
        expect do
          add_score
        end.to change{grant_submission.all_scored_criteria.length}.by 1
      end
    end

    context '#scores_by_criterion' do
      it 'returns only scored criteria score' do
        expect(grant_submission.scores_by_criterion(grant.criteria.first)).not_to include nil
        expect(grant_submission.scores_by_criterion(grant.criteria.first).length).to be 1
        expect do
          add_score
        end.to change{grant_submission.scores_by_criterion(grant.criteria.first).length}.by 1
      end
    end
  end
end
