FactoryBot.define do
  sequence :title

  factory :grant_submission_form, class: 'GrantSubmission::Form' do
    association             :grant, factory: :grant
    association             :form_created_by, factory: :user
    association             :form_updated_by, factory: :user
    disabled                { false }
    submission_instructions { Faker::Lorem.sentence(1) }

    after(:create) do |form|
      section = create(:grant_submission_section, grant_submission_form_id: form.id)
      create(:short_text_question, grant_submission_section_id: section.id)
    end

    trait :disabled do
      disabled { true }
    end

    factory :disabled_grant_submission_form, traits: %i[disabled]
  end
end
