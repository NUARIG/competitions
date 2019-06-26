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

    trait :with_section_and_section do
      after(:create) do |form|
        section = create(:grant_submission_section, form: form,
                                                    form_created_by: form.created_id,
                                                    form_updated_by: form.created_id)
        create(:grant_submission_question, section: section)
      end
    end

    factory :disabled_grant_submission_form,                  traits: %i[disabled]
    factory :grant_submission_form_with_section_and_question, traits: %i[with_section]
  end
end
