FactoryBot.define do
  factory :grant do
    sequence(:name)       { |n| "Grant Name #{n}" }
    sequence(:short_name) { |n| "GN#{n}" }
    organization
  end
end
