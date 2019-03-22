# frozen_string_literal: true

FactoryBot.define do
  factory :string_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'StringQuestion' }
    text             { 'Project Title' }
    help_text        { 'The title of your project' }
    required         { true }
  end

  factory :integer_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'IntegerQuestion' }
    text             { 'Team Size' }
    help_text        { 'How many people will be working on this project?' }
    required         { false }
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
