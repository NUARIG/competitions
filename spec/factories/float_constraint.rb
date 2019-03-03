FactoryBot.define do
  factory :float_constraint, class: 'FloatConstraint' do
    name       { 'maximum_value' }
    value_type { 'float' }
    default    { 'nil' }
  end

  factory :minimum_value_float_constraint, class: 'FloatConstraint' do
    name       { 'minimum_value' }
    value_type { 'float' }
    default    { '1.00' }
  end

  factory :maximum_value_float_constraint, class: 'FloatConstraint' do
    name       { 'maximum_value' }
    value_type { 'float' }
    default    { '1000.00' }
  end
end
