# frozen_string_literal: true

FactoryBot.define do
  factory :string_constraint, class: 'StringConstraint' do
    name       { 'maximum_number_of_characters' }
    value_type { 'integer' }
    default    { '255' }
  end

  factory :string_minimum_number_of_characters_constraint, class: 'StringConstraint' do
    name       { 'minimum_number_of_characters' }
    value_type { 'integer' }
    default    { '0' }
  end

  factory :string_maximum_number_of_characters_constraint, class: 'StringConstraint' do
    name       { 'maximum_number_of_characters' }
    value_type { 'integer' }
    default    { '255' }
  end
end
