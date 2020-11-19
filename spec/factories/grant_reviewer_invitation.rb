FactoryBot.define do
  factory :grant_reviewer_invitation, class: 'GrantReviewer::Invitation' do
    grant       { create(:published_open_grant_with_users) }
    inviter     { grant.admins.first }
    email       { Faker::Internet.email }
    created_at  { DateTime.now }
  end
end
