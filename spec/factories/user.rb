# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name        { Faker::Name.first_name }
    last_name         { Faker::Name.last_name }
    email             { Faker::Internet.email }
    password          { 'secret' }
    organization_role { 'none' }

    trait :admin do
      organization_role { 'admin' }
    end

    factory :organization_admin_user, traits: %i[admin]
  end
end
