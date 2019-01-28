class ConstraintField < ApplicationRecord
  belongs_to :constraint
  belongs_to :field

  validates :value, with: :value_is_a_constraint_type

  private
    def value_is_a_constraint_type
      return if value == 'nil' || value.nil?

      send("value_is_#{constraint.value_type}")
    end

    def value_is_integer
      unless Integer(value, exception: false)
        errors.add(:value, 'must be an integer.')
      end
    end

    def value_is_string
      # will this need to be implemented?
    end

    def value_is_float
      unless Float(value, exception: false)
        errors.add(:value, 'must be a number.')
      end
    end

end
