class Constraint < ApplicationRecord
  include ActiveModel::Validations

  has_many :constraint_fields
  has_many :fields, through: :constraint_fields

  enum value_type: %w[Integer String]

  validates :name, presence: true
  validates_length_of :name, minimum: 4
  validate :value_is_of_type_value_type

  private
    def value_is_of_type_value_type
      return if default.nil? || default == 'nil'

      send("default_is_#{value_type.downcase}")
    end

    def default_is_integer
      unless Integer(default, exception: false)
        errors.add(:default, 'value must be an integer.')
      end
    end

    def default_is_string
      # will this need to be implemented?
    end

    def default_is_float
      # to be implemented
    end
end
