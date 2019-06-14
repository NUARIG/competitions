FactoryBot.define do
  factory :grant_submission_form, class: 'GrantSubmission::Form' do
    association :grant, factory: :grant
    form_created_by  { :user }
    form_updated_by  { :user }
    disabled    { false }
    title       { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
  end
end
