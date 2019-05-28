# frozen_string_literal: true

FactoryBot.define do
  factory :admin_grant_permission, class: 'GrantPermission' do
    association :grant, factory: :grant
    association :user, factory: :user
    role { 'admin' }

    trait :editor do
      role { 'editor' }
    end

    trait :editor do
      role { 'viewer' }
    end

    factory :editor_grant_permission, traits: %i[editor]
    factory :viewer_grant_permission, traits: %i[viewer]
  end
end