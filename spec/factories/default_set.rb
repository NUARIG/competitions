# frozen_string_literal: true

FactoryBot.define do
  sequence :default_set_name do |n|
    "Default Set #{n}"
  end

  factory :default_set do
    name { generate(:default_set_name) }

    trait :with_question do
      after(:create) do |set|
        create(:default_set_string_question, default_set: set)
      end
    end

    trait :with_questions do
      after(:create) do |set|
        create(:default_set_string_question, default_set: set)
        create(:default_set_integer_question, default_set: set)
      end
    end
  end
end
