FactoryBot.define do
  factory :grant_reviewer do
    grant { create(:grant) }
    reviewer { create(:saml_user) }
  end
end
