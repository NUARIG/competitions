# frozen_string_literal: true

FactoryBot.define do
  factory :string_constraint, class: 'StringConstraint' do
    name       { 'maximum_length' }
    value_type { 'integer' }
    default    { '255' }
  end

  factory :string_minimum_length_constraint, class: 'StringConstraint' do
    name       { 'minimum_length' }
    value_type { 'integer' }
    default    { '0' }
  end

  factory :string_maximum_length_constraint, class: 'StringConstraint' do
    name       { 'maximum_length' }
    value_type { 'integer' }
    default    { '255' }
  end
end
