# frozen_string_literal: true

FactoryBot.define do
  factory :default_set do
    sequence(:name) { |n| "Default Question Set #{n}" }

    factory :default_set_with_questions do
      transient do
        questions_count { 3 }
      end
    end
  end
end
