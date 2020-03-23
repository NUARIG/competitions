# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_submission, class: 'GrantSubmission::Submission' do
    association   :grant, factory: :grant
    association   :form,  factory: :grant_submission_form
    association   :applicant, factory: :user
    title         { Faker::Lorem.sentence }
    state         { GrantSubmission::Submission::SUBMISSION_STATES[:submitted] }
    submitted_at  { Time.now }

    trait :draft do
      state         { GrantSubmission::Submission::SUBMISSION_STATES[:draft] }
      submitted_at  nil
    end

    trait :with_responses do
      after(:create) do |submission|
        submission.grant.questions.each do |question|
          case question.response_type.to_sym
          when :short_text
            create(:string_val_response,        submission: submission,
                                                question: question)
          when :number
            create(:number_response,            submission: submission,
                                                question: question)
          when :long_text
            create(:text_val_response,          submission: submission,
                                                question: question)
          when :date_opt_time
            create(:date_opt_time_response,     submission: submission,
                                                question: question)
          when :pick_one
            create(:pick_one_response,          submission: submission,
                                                question: question)
          when :file_upload
            create(:valid_file_upload_response, submission: submission,
                                                question: question)
          end
        end
      end
    end

    factory :submission_with_responses,       traits: %i[with_responses]
    factory :draft_submission,                traits: %i[draft]
    factory :draft_submission_with_responses, traits: %i[draft with_responses]
  end
end
