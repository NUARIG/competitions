# frozen_string_literal: true

FactoryBot.define do
  factory :text_constraint, class: 'TextConstraint' do
    name       { 'maximum_number_of_characters' }
    value_type { 'integer' }
    default    { '255' }
  end

  factory :text_minimum_number_of_characters_constraint, class: 'TextConstraint' do
    name       { 'minimum_number_of_characters' }
    value_type { 'integer' }
    default    { '10' }
  end

  factory :text_maximum_number_of_characters_constraint, class: 'TextConstraint' do
    name       { 'maximum_number_of_characters' }
    value_type { 'integer' }
    default    { '1000' }
  end
end
