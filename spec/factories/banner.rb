FactoryBot.define do
  factory :banner do
    body           { Faker::Lorem.sentence }
    visible        { true }

    trait :invisible do
      visible      { false }
    end

    trait :long do
      body          { Faker::Lorem.paragraph }
    end

    factory :invisible_banner,            traits: %i[invisible]
    factory :long_banner,                 traits: %i[long]
    factory :invisible_long_banner,       traits: %i[long invisible]
  end
end
