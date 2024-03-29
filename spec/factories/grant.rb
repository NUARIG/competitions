# frozen_string_literal: true

FactoryBot.define do
  factory :grant do
    sequence(:name)              { |n| "Grant Name #{n}" }
    sequence(:slug)              { |n| "GN#{n}" }
    publish_date                 { Date.current }
    submission_open_date         { 10.day.from_now }
    submission_close_date        { 20.days.from_now }
    rfa                          { Faker::Lorem.paragraph }
    applications_per_user        { 1 }
    review_guidance              { Faker::Lorem.paragraph }
    max_reviewers_per_submission { 1 }
    max_submissions_per_reviewer { 1 }
    review_open_date             { 30.days.from_now }
    review_close_date            { 40.days.from_now }

    after(:create) do |grant|
      create(:mandatory_criterion, grant: grant)
      create(:mandatory_criterion, grant: grant)
      create(:mandatory_criterion_with_comment, grant: grant)
    end

    trait :new do
      state {  }
    end

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

    trait :not_yet_open do
      publish_date           { 3.days.ago }
      submission_open_date   { 1.day.from_now }
      submission_close_date  { 2.days.from_now }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :open do
      publish_date           { 2.days.ago }
      submission_open_date   { 1.day.ago }
      submission_close_date  { 1.day.from_now }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :closed do
      publish_date           { 3.days.ago }
      submission_open_date   { 2.day.ago }
      submission_close_date  { 1.days.ago }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :not_yet_open do
      publish_date           { 3.days.ago }
      submission_open_date   { 1.day.from_now }
      submission_close_date  { 2.days.from_now }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :with_users do
      after(:create) do |grant|
        create(:admin_grant_permission, grant: grant)
        create(:editor_grant_permission, grant: grant)
        create(:viewer_grant_permission, grant: grant)
      end
    end

    trait :with_users_and_submission_form do
      after(:create) do |grant|
        admin  = create(:admin_grant_permission, grant: grant)
        editor = create(:editor_grant_permission, grant: grant)
        viewer = create(:viewer_grant_permission, grant: grant)
        create(:grant_submission_form_with_section, grant: grant,
                                                    form_created_by: admin.user,
                                                    form_updated_by: admin.user)
      end
    end

    trait :with_submission do
      after(:create) do |grant|
        submitter = create(:saml_user)
        create(:submission_with_responses_with_applicant,  grant: grant,
                                                            form: grant.form,
                                                            submitter: submitter,
                                                            user_updated_at: grant.submission_close_date - 1.minute)

      end
    end

    trait :with_reviewer do
      after(:create) do |grant|
        grant_reviewer = create(:grant_reviewer, grant: grant)
      end
    end

    trait :with_panel do
      after(:create) do |grant|
        panel = create(:panel,  grant: grant)
      end
    end

    trait :bypass_validations do
      to_create { |grant| grant.save(validate: false) }
    end

    trait :with_unrequired_commentable_criterion do
      after(:create) do |grant|
        create(:criterion, grant: grant, show_comment_field: true)
      end
    end

    factory :new_grant,                                     traits: %i[new]
    factory :new_grant_with_users,                          traits: %i[new with_users]
    factory :draft_grant,                                   traits: %i[draft with_users_and_submission_form with_reviewer with_panel]
    factory :published_grant,                               traits: %i[published with_users_and_submission_form]
    factory :open_grant_with_users,                         traits: %i[published open with_users]
    factory :closed_grant_with_users,                       traits: %i[closed with_users]
    factory :published_open_grant,                          traits: %i[published open]
    factory :published_open_grant_with_users,               traits: %i[published open with_users_and_submission_form with_panel]
    factory :published_closed_grant,                        traits: %i[published closed]
    factory :published_closed_grant_with_users,             traits: %i[published closed with_users_and_submission_form with_submission with_reviewer with_panel]
    factory :published_not_yet_open_grant,                  traits: %i[published not_yet_open]
    factory :published_not_yet_open_grant_with_users,       traits: %i[published not_yet_open with_users]
    factory :completed_grant,                               traits: %i[completed closed]
    factory :draft_open_grant,                              traits: %i[draft open with_users_and_submission_form]
    factory :draft_closed_grant,                            traits: %i[draft closed]
    factory :grant_with_users,                              traits: %i[published with_users_and_submission_form with_panel]
    factory :demo_grant_with_users,                         traits: %i[demo with_users]
    factory :draft_grant_with_users,                        traits: %i[draft with_users with_users_and_submission_form with_panel]
    factory :completed_grant_with_users,                    traits: %i[completed with_users]

    factory :open_grant_with_users_and_form_and_submission,                     traits: %i[published open with_users_and_submission_form with_submission]
    factory :open_grant_with_users_and_form_and_submission_and_reviewer,        traits: %i[published open with_users_and_submission_form with_submission with_reviewer with_panel]
    factory :draft_open_grant_with_users_and_form_and_submission_and_reviewer,  traits: %i[draft open with_users_and_submission_form with_submission with_reviewer with_panel]
    factory :closed_grant_with_users_and_form_and_submission_and_reviewer,      traits: %i[published closed with_users_and_submission_form with_submission with_reviewer with_panel]
  end
end
