# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:name)       { |n| "College University #{n}" }
    sequence(:slug)       { |n| "CU#{n}" }
    sequence(:url)        { |n| "http://collegeu#{n}.edu" }
  end
end
