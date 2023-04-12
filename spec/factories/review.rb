# frozen_string_literal: true

FactoryBot.define do
  sequence(:overall_impact_comment) { |n| "Overall comment #{n}" }

  factory :review do
    association :submission, factory: :grant_submission_submission
    association :assigner,   factory: :saml_user
    association :reviewer,   factory: :saml_user

    trait :incomplete do
      overall_impact_score   {}
      overall_impact_comment {}
    end

    trait :reminded do
      reminded_at { 1.day.ago }
    end

    trait :draft do
      draft { true }
    end

    trait :with_score do
      overall_impact_score { rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE) }
    end

    trait :with_comment do
      overall_impact_comment { Faker::Lorem.paragraph }
    end

    trait :with_scored_mandatory_criteria_review do
      after(:create) do |review|
        review.grant_criteria.each do |criterion|
          create(:scored_criteria_review, criterion: criterion, review: review)
        end
      end
    end

    trait :with_scored_and_commented_criteria_review do
      after(:create) do |review|
        review.grant_criteria.each do |criterion|
          criterion.update(show_comment_field: true)
          create(:scored_commented_criteria_review, criterion: criterion, review: review)
        end
      end
    end

    trait :reload_submission do
      after(:create) do |review|
        # ensures current calculations are loaded
        review.submission.reload
      end
    end

    factory :incomplete_review,                                   traits: %i[incomplete reload_submission]
    factory :draft_review,                                        traits: %i[ reload_submission]
    factory :review_with_score,                                   traits: %i[with_score reload_submission]
    factory :review_with_comment,                                 traits: %i[with_comment reload_submission]
    factory :review_with_score_and_comment,                       traits: %i[with_score with_comment reload_submission]
    factory :scored_review_with_scored_mandatory_criteria_review, traits: %i[with_score with_scored_mandatory_criteria_review reload_submission]
    factory :scored_review_with_scored_commented_criteria_review, traits: %i[with_score with_comment with_scored_and_commented_criteria_review reload_submission]
    factory :reminded_review,                                     traits: %i[incomplete reminded reload_submission]
  end
end
