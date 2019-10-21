# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_question, class: 'GrantSubmission::Question' do
    association   :section, factory: :grant_submission_section
    text          { Faker::Lorem.question }
    instruction   { Faker::Lorem.sentence }
    display_order { 1 }
    is_mandatory  { false }
    response_type { 'short_text' }

    trait :required do
      is_mandatory { true }
    end

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

    trait :multiple_choice_option do
      response_type { 'pick_one' }
    end

    trait :with_options do
      before(:create) do |question|
        2.times do |i|
          question.multiple_choice_options << build(:multiple_choice_option, display_order: (i+1))
        end
      end
    end

    factory :short_text_question,                   traits: %i[short_text]
    factory :long_text_question,                    traits: %i[long_text]
    factory :number_question,                       traits: %i[number]
    factory :date_question,                         traits: %i[date]
    factory :multiple_choice_question,              traits: %i[multiple_choice_option]
    factory :multiple_choice_question_with_options, traits: %i[multiple_choice_option with_options]
  end
end


