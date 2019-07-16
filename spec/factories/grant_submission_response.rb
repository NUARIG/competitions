FactoryBot.define do
  factory :grant_submission_response, class: 'GrantSubmission::Response' do
    association :submission, factory: :grant_submission_submission
    association :question,   factory: :grant_submission_question
    grant_submission_multiple_choice_option_id  { nil }
    string_val   { nil }
    text_val     { nil }
    decimal_val  { nil }
    datetime_val { nil }
    boolean_val  { nil }

    trait :string_val do
      string_val { Faker::Lorem.words }
    end

    trait :text_val do
      text_val { Faker::Lorem.paragraphs }
    end

    trait :number do
      decimal_val { Faker::Lorem.number(5) }
    end

    # trait :date do
    #   datetime_val {  }
    # end

    factory :string_val_response, traits: %i[string_val]
    factory :text_val_reponse,    traits: %i[text_val]
    factory :number_reponse,      traits: %i[number]
  end
end
