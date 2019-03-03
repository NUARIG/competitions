FactoryBot.define do
  factory :string_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'StringQuestion' }
    name             { 'Project Title' }
    help_text        { 'The title of your project' }
    placeholder_text { '' }
    required         { true }
  end

  factory :integer_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'IntegerQuestion' }
    name             { 'Team Size' }
    help_text        { 'How many people will be working on this project?' }
    placeholder_text { 'Including yourself' }
    required         { false }
  end

  factory :float_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'FloatQuestion' }
    name             { 'Budget Amount' }
    help_text        { 'Your budget amount?' }
    placeholder_text { '0.00' }
    required         { false }
  end

  factory :text_question, class: 'Question' do
    association      :grant, factory: :grant
    answer_type      { 'TextQuestion' }
    name             { 'Abstract' }
    help_text        { 'Description of your project' }
    placeholder_text { '' }
    required         { true }
  end
end
