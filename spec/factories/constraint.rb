FactoryBot.define do
  factory :integer_constraint do
    type       { 'IntegerConstraint' }
    name       { 'Minimum Value' }
    value_type { 'Integer' }
    default    { '1' }
  end

  factory :string_constraint do
    type       { 'StringConstraint' }
    name       { 'Maximum Length' }
    value_type { 'Integer' }
    default    { '255' }
  end
end
