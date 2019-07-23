class CriteriaReview < ApplicationRecord
  include WithScoring

  belongs_to :criterion
  belongs_to :review

  validates_numericality_of :score, only_integer: true,
                                    unless: -> { score.blank? }
  validates_numericality_of :score, greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? }
  validates_numericality_of :score, less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? }

  validate :score_if_mandatory, if: -> { criterion.is_mandatory? }

  private

  def score_if_mandatory
    errors.add(:base, :required_score, criterion: criterion.name) if score.blank?
  end

end
