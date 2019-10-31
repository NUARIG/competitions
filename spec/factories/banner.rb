FactoryBot.define do
  factory :banner do
    body           { Faker::Lorem.sentence }
    visible        { true }

    trait :invisible do
      visible      { false }
    end

    factory :invisible_banner,            traits: %i[invisible]
  end
end
