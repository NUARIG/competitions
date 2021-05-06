# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_submission, class: 'GrantSubmission::Submission' do
    grant           { create(:grant_with_users) }
    form            { grant.form }
    association     :submitter, factory: :saml_user
    title           { Faker::Lorem.sentence }
    state           { GrantSubmission::Submission::SUBMISSION_STATES[:submitted] }
    user_updated_at { grant.submission_close_date - 1.hour }

    trait :draft do
      state           { GrantSubmission::Submission::SUBMISSION_STATES[:draft] }
      user_updated_at { nil }
    end

    trait :with_applicant do
      after(:create) do |submission|
        create(:grant_submission_applicant, submission: submission, user: submission.submitter)
      end
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

    trait :with_review do
      after(:create) do |submission|
        grant     = submission.grant
        assigner  = grant.admins.first.present? ? grant.admins.first : create(:grant_permission, grant: grant).user
        reviewer  = create(:grant_reviewer, grant: grant).reviewer
        review    = create(:scored_review_with_scored_mandatory_criteria_review,  submission: submission,
                                                                                  assigner: assigner,
                                                                                  reviewer: reviewer,
                                                                                  created_at: grant.review_close_date - 1.hour)
      end
    end

    factory :submission_with_responses,                         traits: %i[with_responses]
    factory :submission_with_responses_with_applicant,          traits: %i[with_applicant with_responses]
    factory :draft_submission,                                  traits: %i[draft]
    factory :draft_submission_with_responses,                   traits: %i[draft with_responses]
    factory :draft_submission_with_responses_with_applicant,    traits: %i[draft with_applicant with_responses]
    factory :reviewed_submission,                               traits: %i[with_responses with_review]
  end
end
