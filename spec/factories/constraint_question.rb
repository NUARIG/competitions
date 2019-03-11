# frozen_string_literal: true

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

  factory :string_minimum_length_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :string_minimum_length_constraint
    cq.association :question, factory: :string_question
    value { '10' }
  end

  factory :string_maximum_length_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :string_maximum_length_constraint
    cq.association :question, factory: :string_question
    value { '15' }
  end

  factory :text_minimum_length_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :text_minimum_length_constraint
    cq.association :question, factory: :text_question
    value { '10' }
  end

  factory :text_maximum_length_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :text_maximum_length_constraint
    cq.association :question, factory: :text_question
    value { '15' }
  end

  factory :integer_minimum_value_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :minimum_value_integer_constraint
    cq.association :question, factory: :string_question
    value { '100' }
  end

  factory :integer_maximum_value_constraint_question, class: 'ConstraintQuestion' do |cq|
    cq.association :constraint, factory: :maximum_value_integer_constraint
    cq.association :question, factory: :string_question
    value { '150' }
  end
end
