# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_question, class: 'GrantSubmission::Question' do
    association   :section, factory: :grant_submission_section
    text          { Faker::Lorem.question }
    instruction   { Faker::Lorem.sentence }
    display_order { 1 }
    is_mandatory  { false }
    response_type { 'short_text' }

    trait :short_text do
      response_type { 'short_text' }
    end

    trait :long_text do
      response_type { 'long_text' }
    end

    trait :number do
      response_type { 'number' }
    end

    trait :date do
      response_type { 'date_opt_time' }
    end

    trait :pick_one do
      response_type { 'pick_one' }
    end

    trait :file_upload do
      response_type { 'file_upload' }
    end

    trait :with_options do
      after(:build) do |question|
        2.times do |i|
          question.multiple_choice_options << build(:multiple_choice_option, question: question, display_order: (i+1))
        end
      end
    end

    factory :short_text_question,            traits: %i[short_text]
    factory :long_text_question,             traits: %i[long_text]
    factory :number_question,                traits: %i[number]
    factory :date_question,                  traits: %i[date]
    factory :pick_one_question,              traits: %i[pick_one]
    factory :pick_one_question_with_options, traits: %i[pick_one with_options]
    factory :file_upload_question,           traits: %i[file_upload]
  end
end


