# frozen_string_literal: true

class FloatConstraint < Constraint
  ALLOWED_NAMES = { maximum_value: 'maximum_value',
                    minimum_value: 'minimum_value' }.freeze

  enum name: ALLOWED_NAMES, _prefix: true
end
