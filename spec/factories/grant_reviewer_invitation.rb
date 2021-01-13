FactoryBot.define do
  factory :grant_reviewer_invitation, class: 'GrantReviewer::Invitation' do
    grant       { create(:published_open_grant_with_users) }
    inviter     { grant.admins.first }
    email       { Faker::Internet.email }
    created_at  { DateTime.now }

    trait :saml do
      email { Faker::Internet.email(domain: COMPETITIONS_CONFIG[:devise][:registerable][:saml_domains].last) }
    end

    trait :registerable do
      email { Faker::Internet.email(domain: 'gmailyahoo.org') }
    end

    # TODO: using configured restricted_domains
    # trait :invalid do
  end
end
