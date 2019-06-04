# frozen_string_literal: true

FactoryBot.define do
  factory :default_set_string_question, class: 'DefaultSetQuestion' do |dsq|
    dsq.association :question, factory: %i[string_question with_constraints]
    dsq.association :default_set, factory: :default_set
  end

  factory :default_set_integer_question, class: 'DefaultSetQuestion' do |dsq|
    dsq.association :question, factory: %i[integer_question with_constraints]
    dsq.association :default_set, factory: :default_set
  end
end
