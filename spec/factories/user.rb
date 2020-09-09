# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name                  { Faker::Name.first_name }
    last_name                   { Faker::Name.last_name }
    sequence(:email)            { |n| Faker::Internet.email(name: "user#{n}")  }
    uid                         { email }
    system_admin                { false }
    grant_creator               { false }
    current_sign_in_at          { Time.now }
    type                        { 'SamlUser' }

    trait :saml do
      type                      { 'SamlUser' }
      session_index             { Faker::Lorem.characters }
    end

    trait :registered do
      confirmed_at              { Time.now }
      type                      { 'RegisteredUser' }
      password                  { Faker::Lorem.characters(number: rand(Devise.password_length)) }
    end

    trait :unconfirmed do
      type                      { 'RegisteredUser' }
      password                  { Faker::Lorem.characters(number: rand(Devise.password_length)) }
      confirmed_at              { nil }
      current_sign_in_at        { nil }
    end

    trait :system_admin do
      system_admin { true }
    end

    trait :grant_creator do
      grant_creator { true }
    end

    factory :saml_user, parent: :user, class: 'SamlUser', traits: %i[saml]
    factory :registered_user, parent: :user, class: 'RegisteredUser', traits: %i[registered]
    factory :unconfirmed_user, parent: :user, class: 'RegisteredUser', traits: %i[unconfirmed]
    factory :system_admin_saml_user, parent: :user, class: 'SamlUser', traits: %i[saml system_admin]
    factory :grant_creator_saml_user, parent: :user, class: 'SamlUser', traits: %i[saml grant_creator]
    factory :system_admin_registered_user, parent: :user, class: 'RegisteredUser',  traits: %i[registered system_admin]
    factory :grant_creator_registered_user, parent: :user, class: 'RegisteredUser', traits: %i[registered grant_creator]
  end
end
