class Constraint < ApplicationRecord
  include ActiveModel::Validations

  has_many :constraint_fields
  has_many :fields, through: :constraint_fields

  enum value_type: {
    integer: 'integer',
    string:  'string',
    float:   'float'
  }, _suffix: true

  validates :name, presence: true
  validates_length_of :name, minimum: 4
  validate :default_is_a_value_type

  private
    def default_is_a_value_type
      return if default.nil? || default == 'nil'
      begin
        send("default_is_#{value_type}")
      rescue
        errors.add(:value_type, 'must be specified.')
      end
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
      unless Float(default, exception: false)
        errors.add(:default, 'value must be a number.')
      end
    end
end
