FactoryBot.define do
  factory :grant_submission_response, class: 'GrantSubmission::Response' do
    association :submission, factory: :grant_submission_submission
    association :question,   factory: :grant_submission_question
    grant_submission_multiple_choice_option_id  { nil }
    string_val   { nil }
    text_val     { nil }
    decimal_val  { nil }
    datetime_val { nil }

    trait :string_val do
      string_val { Faker::Lorem.sentence }
    end

    trait :text_val do
      association :question, factory: :long_text_question
      text_val { Faker::Lorem.paragraphs }
    end

    trait :number do
      association :question, factory: :number_question
      decimal_val { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    end

    trait :datetime do
      association :question, factory: :date_question
      datetime_val { DateTime.now.to_s }
    end

    trait :pick_one do
      association :question, factory: :pick_one_question
    end

    trait :with_pdf do
      association :question, factory: :file_upload_question
      document { Rack::Test::UploadedFile.new('spec/support/file_upload/text_file.pdf', 'application/pdf') }
    end

    trait :with_invalid_file do
      association :question, factory: :file_upload_question
      document { Rack::Test::UploadedFile.new('spec/support/file_upload/text_file.txt', 'text/plain') }
    end

    factory :string_val_response,          traits: %i[string_val]
    factory :text_val_response,            traits: %i[text_val]
    factory :number_response,              traits: %i[number]
    factory :valid_file_upload_response,   traits: %i[with_pdf]
    factory :invalid_file_upload_response, traits: %i[with_invalid_file]
    factory :pick_one_response,            traits: %i[pick_one]
    factory :date_opt_time_response,       traits: %i[datetime]
  end
end
