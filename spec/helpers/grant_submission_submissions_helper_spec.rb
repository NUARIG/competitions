require 'rails_helper'

RSpec.describe GrantSubmissions::SubmissionsHelper, type: :helper do
  let(:user) 		 { create(:user) }
  let(:submission) { create(:submission_with_responses_with_applicant) }
  let(:applicant2) { create(:grant_submission_submission_applicant, submission: submission, applicant: user)}


  context '#applicant_label' do
  	it 'reads Applicant with one submission_applicant' do
  	  expect(applicant_label(submission.applicants)).to eql 'Applicant:'
  	end 

  	it 'reads Applicants with more than one submission applicant' do
  	  applicant2.touch
  	  expect(applicant_label(submission.applicants)).to eql 'Applicants:'
  	end
  end
end