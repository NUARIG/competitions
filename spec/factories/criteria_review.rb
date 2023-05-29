FactoryBot.define do
  factory :criteria_review do
    association :criterion, factory: :criterion
    association :review,    factory: :review
    score       { nil }
    comment     { nil }
    draft       { false }

    trait :draft do
      draft { true }
    end

    trait :scored do
      score { rand(Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE) }
    end

    trait :commented do
      comment { Faker::Lorem.sentence }
    end

    factory :draft_criteria_review,            traits: %i[draft]
    factory :scored_draft_criteria_review,     traits: %i[draft scored]
    factory :scored_criteria_review,           traits: %i[scored]
    factory :commented_criteria_review,        traits: %i[commented]
    factory :scored_commented_criteria_review, traits: %i[scored commented]
  end
end
