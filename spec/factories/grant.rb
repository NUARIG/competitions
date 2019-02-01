FactoryBot.define do
  factory :grant do
    association :organization, factory: :organization
    association :user, factory: :user
    sequence(:name)             { |n| "Grant Name #{n}" }
    sequence(:short_name)       { |n| "GN#{n}" }
    state                       { 'complete' }
    initiation_date             { Date.current }
    submission_open_date        { 1.day.from_now }
    submission_close_date       { 2.days.from_now }
    rfa                         { Faker::Lorem.paragraph }
    min_budget                  { 1 }
    max_budget                  { 100 }
    applications_per_user       { 1 }
    review_guidance             { Faker::Lorem.paragraph }
    max_reviewers_per_proposal  { 1 }
    max_proposals_per_reviewer  { 1 }
    panel_date                  { 30.days.from_now }
    panel_location              { Faker::Address.full_address }
  end
end
