# frozen_string_literal: true

FactoryBot.define do
  factory :grant_permission, class: 'GrantPermission' do
    association :grant, factory: :grant
    association :user, factory: :user
    role { 'admin' }

    trait :admin do
      association :user, factory: :grant_creator_user
    end

    trait :editor do
      role { 'editor' }
    end

    trait :viewer do
      role { 'viewer' }
    end

    factory :admin_grant_permission,  traits: %i[admin]
    factory :editor_grant_permission, traits: %i[editor]
    factory :viewer_grant_permission, traits: %i[viewer]
  end
end
