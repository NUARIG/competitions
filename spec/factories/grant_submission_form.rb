FactoryBot.define do
  sequence :title

  factory :grant_submission_form, class: 'GrantSubmission::Form' do
    association             :grant, factory: :grant
    association             :form_created_by, factory: :user
    association             :form_updated_by, factory: :user
    submission_instructions { Faker::Lorem.sentence }

    trait :with_section do
      after(:create) do |form|
        section = create(:grant_submission_section, grant_submission_form_id: form.id)
        create(:short_text_question, grant_submission_section_id: section.id,
                                     text: 'Short Text Question',
                                     display_order: 1)
        create(:number_question,     grant_submission_section_id: section.id,
                                     text: 'Number Question',
                                     display_order: 2)
        create(:long_text_question,  grant_submission_section_id: section.id,
                                     text: 'Long Text Question',
                                     display_order: 3)
        create(:multiple_choice_question_with_options, grant_submission_section_id: section.id,
                                     text: 'Multiple Choice Question',
                                     display_order: 4)
      end
    end

    trait :disabled do
      disabled { true }
    end

    factory :disabled_grant_submission_form,     traits: %i[disabled]
    factory :grant_submission_form_with_section, traits: %i[with_section]
  end
end
