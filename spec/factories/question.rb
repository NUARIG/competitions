FactoryBot.define do
  factory :string_question, class: 'Question' do
    association      :field, factory: :string_field
    association      :grant, factory: :grant
    name             { 'Project Title' }
    help_text        { 'The title of your project' }
    placeholder_text { '' }
    required         { true }
  end

  factory :integer_question, class: 'Question' do
    association      :field, factory: :integer_field
    association      :grant, factory: :grant
    name             { 'Team Size' }
    help_text        { 'How many people will be working on this project?' }
    placeholder_text { 'Including yourself' }
    required         { false }
  end

  factory :float_question, class: 'Question' do
    association      :field, factory: :float_field
    association      :grant, factory: :grant
    name             { 'Budget Amount' }
    help_text        { 'Your budget amount?' }
    placeholder_text { '0.00' }
    required         { false }
  end
end
