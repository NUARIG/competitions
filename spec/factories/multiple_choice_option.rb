# frozen_string_literal: true

FactoryBot.define do
  factory :multiple_choice_option, class: 'GrantSubmission::MultipleChoiceOption' do
    association     :question, factory: :grant_submission_question
    sequence(:text) { |n| "Option #{n}" }
    display_order   { 1 }
  end
end
