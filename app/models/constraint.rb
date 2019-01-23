class Constraint < ApplicationRecord
  has_many :constraint_fields
  has_many :fields, through: :constraint_fields

  enum field_type: ['integer', 'string']
end
