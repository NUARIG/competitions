# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_section, class: 'GrantSubmission::Section' do
    association :grant_submission_form, factory: :grant_submission_form
    title           { Faker::Lorem.sentence }
    display_order   { 1 }
    repeatable      { false}
  end
end
