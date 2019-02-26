class ConstraintQuestion < ApplicationRecord
  belongs_to :constraint
  belongs_to :question

  validates :value, with: :value_is_a_constraint_type

  validates_uniqueness_of :constraint_id,
    scope: :question_id,
    message: 'can only be constrained once'

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

    def value_is_float
      unless Float(value, exception: false)
        errors.add(:value, 'must be a number.')
      end
    end
end
