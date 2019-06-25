# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_section do
    title           { Faker.sentence }
    display_order   { 1 }
    repeatable      { false}
  end
end
