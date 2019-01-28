FactoryBot.define do
  factory :integer_constraint_field, class: 'ConstraintField' do |cf|
    cf.association :constraint, factory: :integer_constraint
    cf.association :field, factory: :integer_field
    value { '10' }
  end

  factory :float_constraint_field, class: 'ConstraintField' do |cf|
    cf.association :constraint, factory: :float_constraint
    cf.association :field, factory: :float_field
    value { '10' }
  end
end
