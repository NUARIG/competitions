# frozen_string_literal: true

FactoryBot.define do
  factory :default_set do
    sequence(:name) { |n| "Default Question Set #{n}" }
  end
end
