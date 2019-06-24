FactoryBot.define do
  factory :grant_submission_form, class: 'GrantSubmission::Form' do
    association :grant, factory: :grant
    form_created_by  { :user }
    form_updated_by  { :user }
    disabled         { false }
    title            { Faker::Lorem.sentence }
    description      { Faker::Lorem.sentence }

    trait :disabled do
      disabled { true }
    end

    factory :disabled_grant_submission_form, traits: %i[disabled]
  end
end
