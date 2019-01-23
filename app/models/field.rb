class Field < ApplicationRecord
  validates :label, presence: true, length: { minimum: 4 }
  validates :help_text, length: { minimum: 4 }, allow_blank: true

  has_many :constraint_fields
  has_many :constraints, through: :constraint_fields
end
require_dependency 'fields/integer_field'
require_dependency 'fields/string_field'
