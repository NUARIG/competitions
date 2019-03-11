# frozen_string_literal: true

FactoryBot.define do
  factory :text_constraint, class: 'TextConstraint' do
    name       { 'maximum_length' }
    value_type { 'integer' }
    default    { '255' }
  end

  factory :text_minimum_length_constraint, class: 'TextConstraint' do
    name       { 'minimum_length' }
    value_type { 'integer' }
    default    { '10' }
  end

  factory :text_maximum_length_constraint, class: 'TextConstraint' do
    name       { 'maximum_length' }
    value_type { 'integer' }
    default    { '1000' }
  end
end
