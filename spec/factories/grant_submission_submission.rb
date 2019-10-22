# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_submission, class: 'GrantSubmission::Submission' do
    association   :grant, factory: :grant
    association   :form,  factory: :grant_submission_form
    association   :applicant, factory: :user
    title         { Faker::Lorem.sentence }

    trait :with_responses do
      after(:create) do |submission|
        submission.grant.questions.each do |question|
          case question.response_type
          when :short_text
            create(:string_val_response, submission: submission, question:   question)
          when :number
            create(:number_response, submission: submission,
                                     question: question)
          when :long_text
            create(:text_val_response, submission: submission,
                                       question: question)
          end
        end
      end
    end

    factory :submission_with_responses, traits: %i[with_responses]
  end
end
