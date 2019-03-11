# frozen_string_literal: true

FactoryBot.define do
  factory :admin_grant_user, class: 'GrantUser' do
    association :grant, factory: :grant
    association :user, factory: :user
    grant_role { 'admin' }
  end

  factory :editor_grant_user, class: 'GrantUser' do
    association      :grant, factory: :grant
    association      :user, factory: :user
    grant_role { 'editor' }
  end

  factory :viewer_grant_user, class: 'GrantUser' do
    association      :grant, factory: :grant
    association      :user, factory: :user
    grant_role { 'viewer' }
  end
end
