class Criterion < ApplicationRecord
  belongs_to :grant,            inverse_of: :criteria
  has_many   :criteria_reviews
  # TODOL: will we need this?
  # has_many   :reviews,          through: :criterion_reviews

  validates_presence_of :name
end
