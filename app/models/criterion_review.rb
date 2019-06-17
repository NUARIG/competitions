class CriterionReview < ApplicationRecord
  belongs_to :criterion
  belongs_to :review

  validates_numericality_of :score, only_integer: true
  validates_numericality_of :score, in: Review::MINIMUM_ALLOWED_SCORE..Review::MAXIMUM_ALLOWED_SCORE
                                    unless: -> { criterion.allow_no_score? }
end
