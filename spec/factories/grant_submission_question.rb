# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_question, class: 'GrantSubmission::Question' do
    association   :grant_submission_section, factory: :grant_submission_section
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

    factory :short_text_question, traits: %i[short_text]
    factory :long_text_question,  traits: %i[long_text]
    factory :number_question,     traits: %i[number]
    factory :date_question,       traits: %i[date]
  end
end


