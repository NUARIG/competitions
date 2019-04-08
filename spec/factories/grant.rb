# frozen_string_literal: true

FactoryBot.define do
  factory :grant do
    association :organization, factory: :organization
    sequence(:name)             { |n| "Grant Name #{n}" }
    sequence(:short_name)       { |n| "GN#{n}" }
    default_set                 { FactoryBot.create(:default_set).id }
    state                       { 'published' }
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

    trait :demo do
      state { 'demo' }
    end

    trait :draft do
      state { 'draft' }
    end

    trait :published do
      state { 'published' }
    end

    trait :completed do
      state { 'completed' }
    end

    trait :open do
      publish_date           { 2.days.ago }
      submission_open_date   { 1.day.ago }
      submission_close_date  { 1.day.from_now }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :closed do
      publish_date           { 3.days.ago }
      submission_open_date   { 1.day.ago }
      submission_close_date  { 2.days.ago }
      to_create { |instance| instance.save(validate: false) }
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
        create(:viewer_grant_user, grant: grant)
      end
    end

    trait :bypass_validations do
      to_create { |grant| grant.save(validate: false) }
    end

    factory :draft_grant,                              traits: %i[draft]
    factory :published_grant,                          traits: %i[published]
    factory :open_grant_with_users_and_questions,      traits: %i[open with_questions with_users]
    factory :closed_grant_with_users_and_questions,    traits: %i[closed with_questions with_users]
    factory :published_open_grant,                     traits: %i[published open]
    factory :published_closed_grant,                   traits: %i[published closed]
    factory :completed_closed_grant,                   traits: %i[completed closed]
    factory :draft_open_grant,                         traits: %i[draft open]
    factory :draft_closed_grant,                       traits: %i[draft closed]
    factory :grant_with_users_and_questions,           traits: %i[with_questions with_users]
    factory :demo_grant_with_users_and_questions,      traits: %i[demo with_questions with_users]
    factory :draft_grant_with_users_and_questions,     traits: %i[draft with_questions with_users]
    factory :completed_grant_with_users_and_questions, traits: %i[completed with_questions with_users]
  end
end
