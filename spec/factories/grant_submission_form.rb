FactoryBot.define do
  factory :grant_submission_form, class: 'GrantSubmission::Form' do
    association :grant, factory: :grant
    created_id  { :user }
    updated_id  { :user }
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
  end
end
