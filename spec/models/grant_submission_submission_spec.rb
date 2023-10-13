require 'rails_helper'

RSpec.describe GrantSubmission::Submission, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:form) }
  it { is_expected.to respond_to(:submitter) }
  it { is_expected.to respond_to(:title) }
  it { is_expected.to respond_to(:reviews) }
  it { is_expected.to respond_to(:reviewers) }
  it { is_expected.to respond_to(:criteria_reviews) }
  it { is_expected.to respond_to(:reviews_count) }
  it { is_expected.to respond_to(:state) }
  it { is_expected.to respond_to(:user_updated_at) }
  it { is_expected.to respond_to(:awarded) }

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

    it 'requires a submitter' do
      submission.submitter = nil
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:submitter)
    end

    it 'requires a title' do
      submission.title = ''
      expect(submission).not_to be_valid
      expect(submission.errors).to include(:title)
    end

    it 'cannot be awarded in draft state' do
      submission.state = 'draft'
      submission.awarded = true
      expect(submission).not_to be_valid
      expect(submission.errors.messages[:base]).to eq ["A submission cannot be awarded when it is in draft mode."]
    end

    it 'cannot be awarded without being reviewed' do
      submission.awarded = true
      expect(submission).not_to be_valid
      expect(submission.errors.messages[:base]).to eq ["A submission must have at least one review before being awarded."]
    end
  end

  describe '#methods' do
    let!(:grant)        { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let!(:submission)   { grant.submissions.first }
    let(:grant_admin)   { grant.grant_permissions.role_admin.first.user }
    let(:scored_review) { create(:scored_review_with_scored_mandatory_criteria_review, submission: submission,
                                                                                       assigner:   grant_admin,
                                                                                       reviewer:   grant.reviewers.first) }
    let(:incomplete_review) { create(:incomplete_review, submission: submission,
                                                     assigner: grant_admin,
                                                     reviewer: grant.reviewers.first) }

    context 'published grant' do
      describe '#destroy' do
        it 'may not be destroyed' do
          expect do
            submission.destroy
          end.not_to change{ GrantSubmission::Submission.count }
          expect(submission.errors[:base]).to include I18n.t('activerecord.errors.models.grant_submission/submission.attributes.base.may_not_delete_from_published_grant')
        end

        it 'does not destroy reviews' do
          incomplete_review.save
          expect do
            submission.destroy
          end.not_to change{ Review.count }
        end
      end
    end

    context 'draft grant' do
      before(:each) do
        grant.update(state: 'draft')
      end

      describe '#destroy' do
        context 'with reviews' do
          context 'scored review' do
            it 'may be deleted' do
              scored_review.save
              expect do
                submission.destroy
              end.to change{GrantSubmission::Submission.count}.by(-1).and change{Review.count}.by(-1)
            end
          end

          context 'incomplete review' do
            it 'may be deleted' do
              incomplete_review.save

              expect do
                submission.destroy
              end.to change{GrantSubmission::Submission.count}.by(-1).and change{Review.count}.by(-1)
            end
          end
        end
      end
    end
  end

  describe 'unsubmit' do
    let(:grant)             { create(:open_grant_with_users_and_form_and_submission_and_reviewer) }
    let(:submission)        { grant.submissions.first }
    let(:grant_admin)       { grant.grant_permissions.role_admin.first.user }

    let(:submitted_scored_review) { create(:scored_review_with_scored_mandatory_criteria_review, :submitted,
                                              submission: submission,
                                              assigner:   grant_admin,
                                              reviewer:   grant.reviewers.first) }
    let(:incomplete_review)       { create(:incomplete_review, 
                                              submission: submission,
                                              assigner: grant_admin,
                                              reviewer: grant.reviewers.first) }

    context 'with no reviews' do
      it 'may be unsubmitted' do
        submission.update(state: GrantSubmission::Submission::SUBMISSION_STATES[:draft])
        expect(submission).to be_valid
      end
    end

    context 'with reviews' do
      context 'unscored' do
        it 'may be unsubmitted' do
          incomplete_review.reload
          submission.update(state: GrantSubmission::Submission::SUBMISSION_STATES[:draft])
          expect(submission.errors).to be_empty
          expect(submission).to be_valid
        end
      end

      context 'scored' do
        it 'may not be unsubmitted' do
          submitted_scored_review.touch
          submission.update(state: GrantSubmission::Submission::SUBMISSION_STATES[:draft])
          expect(submission.errors.messages[:base]).to eq ['This submission has already been scored and may not be edited.']
        end
      end
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
        scored_review.save
        incomplete_review.save
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
        end.to change{grant_submission.reload.all_scored_criteria.length}.by 1
      end
    end

    context '#scores_by_criterion' do
      it 'returns only scored criteria score' do
        expect(grant_submission.scores_by_criterion(grant.criteria.first)).not_to include nil
        expect(grant_submission.scores_by_criterion(grant.criteria.first).length).to be 1
        expect do
          add_score
        end.to change{grant_submission.reload.scores_by_criterion(grant.criteria.first).length}.by 1
      end
    end
  end
end
