# frozen_string_literal: true

FactoryBot.define do
  sequence(:overall_impact_comment) { |n| "Overall comment #{n}" }

  factory :review do
    association :submission, factory: :grant_submission_submission
    association :assigner,   factory: :user
    association :reviewer,   factory: :user
    overall_impact_score   {}
    overall_impact_comment {}

    trait :with_score do
      overall_impact_score { rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE) }
    end

    trait :with_comment do
      overall_impact_comment { Faker::Lorem.paragraph }
    end

    factory :review_with_score,             traits: %i[with_score]
    factory :review_with_comment,           traits: %i[with_comment]
    factory :review_with_score_and_comment, traits: %i[with_score with_comment]
  end
end
