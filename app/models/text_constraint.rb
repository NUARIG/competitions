class TextConstraint < Constraint
  ALLOWED_NAMES = { maximum_length: 'maximum_length',
                    minimum_length: 'minimum_length'
                  }.freeze

  enum name: ALLOWED_NAMES, _prefix: true
end
