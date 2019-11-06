FactoryBot.define do
  factory :grant_creator_request do
    association     :requester, factory: :user
    request_comment { Faker::Lorem.sentences(number: 2) }

    trait :approved do
      status { 'approved' }
    end

    trait :rejected do
      status { 'rejected' }
    end

    trait :reviewed_by_system_admin do
      association :reviewer, factory: :system_admin_user
    end

    factory :approved_grant_creator_request, traits: %i[approved]
    factory :rejected_grant_creator_request, traits: %i[rejected]

    factory :reviewed_approved_grant_creator_request, traits: %i[approved reviewed_by_system_admin]
    factory :reviewed_rejected_grant_creator_request, traits: %i[rejected reviewed_by_system_admin]
  end
end
