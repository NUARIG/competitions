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

    trait :complete do
      state { 'complete' }
    end

    trait :draft do
      state { 'draft' }
    end

    trait :open do
      publish_date                { DateTime.now }
      submission_open_date        { DateTime.now }
      submission_close_date       { 20.days.from_now }
    end

    trait :closed do
      publish_date                { 10.days.from_now }
      submission_open_date        { 10.days.from_now }
      submission_close_date       { 20.days.from_now }
    end

    trait :with_questions do
      after(:create) do |grant|
        create(:string_question, :with_constraints, grant: grant)
        create(:integer_question, :with_constraints, grant: grant)
      end
    end

    trait :with_users do
      after(:create) do |grant|
        create(:admin_grant_user, grant: grant)
        create(:editor_grant_user, grant: grant)
      end
    end

    trait :bypass_validations do
      to_create { |grant| grant.save(validate: false) }
    end

    factory :complete_grant,        traits: %i[complete]
    factory :draft_grant,           traits: %i[draft]
    factory :complete_open_grant,   traits: %i[complete open]
    factory :complete_closed_grant, traits: %i[complete closed]
    factory :draft_open_grant,      traits: %i[draft open]
    factory :draft_closed_grant,    traits: %i[draft closed]


  end
end
