FactoryBot.define do
  factory :string_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'string' }
    name             { 'Project Title' }
    help_text        { 'The title of your project' }
    placeholder_text { '' }
    required         { true }
  end

  factory :integer_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'integer' }
    name             { 'Team Size' }
    help_text        { 'How many people will be working on this project?' }
    placeholder_text { 'Including yourself' }
    required         { false }
  end

  factory :float_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'float' }
    name             { 'Budget Amount' }
    help_text        { 'Your budget amount?' }
    placeholder_text { '0.00' }
    required         { false }
  end
end
