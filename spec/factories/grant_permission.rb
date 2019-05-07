# frozen_string_literal: true

FactoryBot.define do
  factory :admin_grant_permission, class: 'GrantPermission' do
    association :grant, factory: :grant
    association :user, factory: :user
    role { 'admin' }
  end

  factory :editor_grant_permission, class: 'GrantPermission' do
    association      :grant, factory: :grant
    association      :user, factory: :user
    role { 'editor' }
  end

  factory :viewer_grant_permission, class: 'GrantPermission' do
    association      :grant, factory: :grant
    association      :user, factory: :user
    role { 'viewer' }
  end
end
