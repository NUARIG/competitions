# frozen_string_literal: true

FactoryBot.define do
  factory :criterion do
    association :grant, factory: :grant
    name               { Faker::Lorem.sentence(2) }
    description        { Faker::Lorem.paragraph(2) }
    is_mandatory       { false }
    show_comment_field { false }

    trait :mandatory do
      is_mandatory { true }
    end

    trait :allows_no_score do
      allow_no_score     { false }
    end

    trait :shows_comment_field do
      show_comment_field { false }
    end

    factory :mandatory_criterion,              traits: %i[mandatory]
    factory :mandatory_criterion_with_comment, traits: %i[mandatory shows_comment_field]
  end
end
