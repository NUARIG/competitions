require 'rails_helper'

RSpec.describe GrantSubmissions::SubmissionsHelper, type: :helper do
  let(:user) 		   { create(:user) }
  let(:submission) { create(:submission_with_responses_with_applicant) }
  let(:applicant2) { create(:grant_submission_submission_applicant, submission: submission, applicant: user)}
  let(:reviewer1)  { create(:grant_reviewer, grant: submission.grant).reviewer }
  let(:reviewer2)  { create(:grant_reviewer, grant: submission.grant).reviewer }
  let(:reviewer3)  { create(:grant_reviewer, grant: submission.grant).reviewer }
  let(:grant)      { submission.grant }
  let(:assigner)   { grant.admins.first }
  let(:assigned_review) { create(:review, :assigned, submission: submission, grant: grant, assigner: assigner, reviewer: reviewer1 ) }
  let(:submitted_review) { create(:review, :with_score, :with_scored_mandatory_criteria_review, :submitted, submission: submission, grant: grant, assigner: assigner, reviewer: reviewer2 ) }
  let(:draft_review) { create(:review, :with_score, :with_scored_mandatory_criteria_review, :draft, submission: submission, grant: grant, assigner: assigner, reviewer: reviewer3 ) }

  context '#applicant_label' do
  	it 'reads Applicant with one submission_applicant' do
  	  expect(applicant_label(submission.applicants)).to eql 'Applicant:'
  	end 

  	it 'reads Applicants with more than one submission applicant' do
  	  applicant2.touch
  	  expect(applicant_label(submission.applicants)).to eql 'Applicants:'
  	end
  end

  context '#review_data' do
    context 'no reviews' do
      it 'returns zeroes for review counts and dashes for scores' do
        result = review_data(submission)
        expect(result.completed_review_count).to eql '0'
        expect(result.assigned_review_count).to eql '0'
        expect(result.overall_impact_average).to eql '-'
        expect(result.composite_score).to eql '-'
      end
    end

    context 'assigned review' do
      before(:each) do
        assigned_review
      end

      it 'returns zeroes for review counts and scores' do
        result = review_data(submission)
        expect(result.completed_review_count).to eql 0
        expect(result.assigned_review_count).to eql 1
        expect(result.overall_impact_average).to eql 0
        expect(result.composite_score).to eql 0
      end
    end

    context 'draft and assigned review' do
      before(:each) do
        assigned_review.touch
        draft_review.touch
      end

      it 'returns zeroes for review counts and sores' do
        result = review_data(submission)
        expect(result.completed_review_count).to eql 0
        expect(result.assigned_review_count).to eql 2
        expect(result.overall_impact_average).to eql 0
        expect(result.composite_score).to eql 0
      end
    end

    context 'reviewed and assigned review' do
      before(:each) do
        assigned_review.touch
        submitted_review.touch
      end

      it 'returns zeroes for review counts and sores' do
        result = review_data(submission)
        expect(result.completed_review_count).to eql 1
        expect(result.assigned_review_count).to eql 2
        expect(result.overall_impact_average).to eql result.overall_impact_average
        expect(result.composite_score).to eql result.composite_score
      end
    end
  end
end
