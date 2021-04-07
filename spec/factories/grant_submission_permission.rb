# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_permission, class: 'GrantSubmission::Permission' do
    association :submission, factory: :grant_submission_submission
    association :user, factory: :saml_user
  end
end
