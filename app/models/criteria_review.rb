class CriteriaReview < ApplicationRecord
  include WithScoring

  self.table_name = 'criteria_reviews'

  belongs_to :criterion
  belongs_to :review

  validates_presence_of     :score, unless: -> { criterion.allow_no_score? }
  validates_numericality_of :score, only_integer: true,
                                    unless: -> { criterion.allow_no_score? }
  validates_numericality_of :score, greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? && criterion.allow_no_score? }
  validates_numericality_of :score, less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? && criterion.allow_no_score? }
end
