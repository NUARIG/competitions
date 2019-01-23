class ConstraintField < ApplicationRecord
  belongs_to :constraint
  belongs_to :field
end
