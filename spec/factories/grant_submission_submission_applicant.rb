# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_submission_applicant, class: 'GrantSubmission::SubmissionApplicant' do
    association :submission, factory: :grant_submission_submission
    association :applicant, factory: :saml_user
  end
end
