# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_applicant, class: 'GrantSubmission::Applicant' do
    association :submission, factory: :grant_submission_submission
    association :user, factory: :saml_user
  end
end
