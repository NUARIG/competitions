# frozen_string_literal: true

FactoryBot.define do
  factory :grant do
    association :organization, factory: :organization
    sequence(:name)             { |n| "Grant Name #{n}" }
    sequence(:short_name)       { |n| "GN#{n}" }
    default_set                 { FactoryBot.create(:default_set).id }
    state                       { 'complete' }
    publish_date                { Date.current }
    submission_open_date        { 10.day.from_now }
    submission_close_date       { 20.days.from_now }
    rfa                         { Faker::Lorem.paragraph }
    applications_per_user       { 1 }
    review_guidance             { Faker::Lorem.paragraph }
    max_reviewers_per_proposal  { 1 }
    max_proposals_per_reviewer  { 1 }
    review_open_date            { 30.days.from_now }
    review_close_date           { 40.days.from_now }
    panel_date                  { 50.days.from_now }
    panel_location              { Faker::Address.full_address }

    factory :complete_grant do
      state { 'complete' }
    end

    factory :draft_grant do
      state { 'draft' }
    end
  end
end
