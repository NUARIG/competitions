FactoryBot.define do
  factory :integer_constraint, class: 'Constraint' do
    type       { 'IntegerConstraint' }
    name       { 'Minimum Value' }
    value_type { 'integer' }
    default    { '1' }
  end

  factory :float_constraint, class: 'Constraint' do
    type       { 'FloatConstraint' }
    name       { 'Maximum Amount' }
    value_type { 'float' }
    default    { 'nil' }
  end

  factory :string_constraint, class: 'Constraint' do
    type       { 'StringConstraint' }
    name       { 'Maximum Length' }
    value_type { 'integer' }
    default    { '255' }
  end
end
