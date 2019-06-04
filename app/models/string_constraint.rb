# frozen_string_literal: true

class StringConstraint < Constraint
  ALLOWED_NAMES = { maximum_number_of_characters: 'maximum_number_of_characters',
                    minimum_number_of_characters: 'minimum_number_of_characters' }.freeze

  enum name: ALLOWED_NAMES, _prefix: true
end
