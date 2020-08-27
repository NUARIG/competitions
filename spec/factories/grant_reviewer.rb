FactoryBot.define do
  factory :grant_reviewer do
    association :grant,    factory: :grant
    association :reviewer, factory: :saml_user
  end
end
