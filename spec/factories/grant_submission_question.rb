# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_question do
    association   :grant_submission_section, factory: :grant_submission_section
    text          { Faker::Lorem.question }
    instruction   { Faker::Lorem.sentence }
    display_order { 1 }
    is_mandatory  { false }
    response_type { 'short_text' }
  end
end


