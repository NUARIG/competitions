# frozen_string_literal: true

FactoryBot.define do
  sequence(:overall_impact_comment) { |n| "Overall comment #{n}" }

  factory :review do
    association :submission, factory: :grant_submission_submission
    association :assigner,   factory: :user
    association :reviewer,   factory: :user
    overall_impact_score { rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE)}
    overall_impact_comment
  end
end
