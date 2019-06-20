# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_submission do
    association   :grant_submission_form, factory: :grant
    title         { Faker.sentence }
    display_order { 1 }
    repeatable    { false }
  end
end
