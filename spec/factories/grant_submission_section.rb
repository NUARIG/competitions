# frozen_string_literal: true

FactoryBot.define do
  factory :grant_submission_section, class: 'GrantSubmission::Section' do
    association :form, factory: :grant_submission_form
    sequence(:title) { |n| "#{Faker::Lorem.sentence} #{n}" }
    display_order    { 1 }
    repeatable       { false}
  end
end
