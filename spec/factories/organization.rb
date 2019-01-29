FactoryBot.define do
  factory :organization do
    sequence(:name)       { |n| "College University #{n}" }
    sequence(:short_name) { |n| "CU#{n}" }
    sequence(:url)        { |n| "http://collegeu#{n}.edu" }
  end
end
