# frozen_string_literal: true

FactoryBot.define do
  factory :grant_permission, class: 'GrantPermission' do
    association :grant, factory: :grant
    association :user, factory: :saml_user
    submission_notification { false }
    role { 'admin' }

    trait :admin do
      association :user, factory: :grant_creator_saml_user
    end

    trait :editor do
      role { 'editor' }
    end

    trait :viewer do
      role { 'viewer' }
    end

    trait :with_submission_notification do
      submission_notification { true }
    end

    factory :admin_grant_permission,  traits: %i[admin]
    factory :editor_grant_permission, traits: %i[editor]
    factory :viewer_grant_permission, traits: %i[viewer]

    factory :admin_grant_permission_with_submission_notification, traits: %i[admin with_submission_notification]
  end
end
