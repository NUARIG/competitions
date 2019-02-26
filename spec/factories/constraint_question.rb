FactoryBot.define do
  factory :integer_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :integer_constraint
    cq.association :question, factory: :integer_question
    value { '10' }
  end

  factory :float_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :float_constraint
    cq.association :question, factory: :float_question
    value { '10.5' }
  end
end
