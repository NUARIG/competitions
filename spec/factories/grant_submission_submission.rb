# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_submission, class: 'GrantSubmission::Submission' do
    association   :grant, factory: :grant
    association   :form, factory: :grant_submission_form
    association   :applicant, factory: :user
    title         { Faker::Lorem.sentence }

    trait :with_response do
      after(:create) do |submission|
        create(:string_val_response, submission: submission,
                                     question:   submission.grant.questions.first)
      end
    end

    factory :submission_with_response, traits: %i[with_response]
  end
end
