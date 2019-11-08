# frozen_string_literal: true

FactoryBot.define do
  sequence(:overall_impact_comment) { |n| "Overall comment #{n}" }

  factory :review do
    association :submission, factory: :grant_submission_submission
    association :assigner,   factory: :user
    association :reviewer,   factory: :user

    trait :incomplete do
      overall_impact_score   {}
      overall_impact_comment {}
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

    factory :incomplete_review,                                   traits: %i[incomplete]
    factory :review_with_score,                                   traits: %i[with_score]
    factory :review_with_comment,                                 traits: %i[with_comment]
    factory :review_with_score_and_comment,                       traits: %i[with_score with_comment]
    factory :scored_review_with_scored_mandatory_criteria_review, traits: %i[with_score with_scored_mandatory_criteria_review]
  end
end
