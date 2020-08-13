# frozen_string_literal: true

FactoryBot.define do
  factory :saml_user do
    first_name                  { Faker::Name.first_name }
    last_name                   { Faker::Name.last_name }
    sequence(:email)            { |n| Faker::Internet.email(name: "saml_user#{n}")  }
    uid                         { email }
    system_admin                { false }
    grant_creator               { false }
    current_sign_in_at          { Time.now }
    type                        { 'SamlUser' }
    session_index               { Faker::Lorem.characters }

    trait :system_admin do
      system_admin { true }
    end

    trait :grant_creator do
      grant_creator { true }
    end

    factory :system_admin_saml_user,   traits: %i[system_admin]
    factory :grant_creator_saml_user,  traits: %i[grant_creator]
  end
end
