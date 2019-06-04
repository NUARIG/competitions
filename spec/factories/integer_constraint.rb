# frozen_string_literal: true

FactoryBot.define do
  factory :integer_constraint, class: 'IntegerConstraint' do
    name       { 'minimum_value' }
    value_type { 'integer' }
    default    { '1' }
  end

  factory :minimum_value_integer_constraint, class: 'IntegerConstraint' do
    name       { 'minimum_value' }
    value_type { 'integer' }
    default    { '0' }
  end

  factory :maximum_value_integer_constraint, class: 'IntegerConstraint' do
    name       { 'maximum_value' }
    value_type { 'integer' }
    default    { '1000' }
  end
end
