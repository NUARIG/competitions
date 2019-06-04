# frozen_string_literal: true

FactoryBot.define do
  factory :string_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'StringQuestion' }
    text             { 'Project Title' }
    help_text        { 'The title of your project' }
    required         { true }

    trait :with_constraints do
      after(:create) do |string_question|
        create(:string_minimum_number_of_characters_constraint_question, question: string_question)
        create(:string_maximum_number_of_characters_constraint_question, question: string_question)
      end
    end
  end

  factory :integer_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'IntegerQuestion' }
    text             { 'Team Size' }
    help_text        { 'How many people will be working on this project?' }
    required         { false }

    trait :with_constraints do
      after(:create) do |string_question|
        create(:integer_minimum_value_constraint_question, question: string_question)
        create(:integer_maximum_value_constraint_question, question: string_question)
      end
    end
  end

  factory :float_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'FloatQuestion' }
    text             { 'Budget Amount' }
    help_text        { 'Your budget amount?' }
    required         { false }
  end

  factory :text_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'TextQuestion' }
    text             { 'Abstract' }
    help_text        { 'Description of your project' }
    required         { true }
  end
end
