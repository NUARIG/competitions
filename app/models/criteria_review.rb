class CriteriaReview < ApplicationRecord
  include WithScoring
  has_paper_trail versions: { class_name: 'PaperTrail::CriteriaReviewVersion' },
                  meta:     { review_id: :review_id }

  belongs_to :criterion
  belongs_to :review

  has_one :submission, through: :review
  has_one :grant,      through: :review

  validates_uniqueness_of   :criterion_id, scope: :review

  validates_numericality_of :score, only_integer: true,
                                    unless: -> { score.blank? }
  validates_numericality_of :score, greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? }
  validates_numericality_of :score, less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? }

  validate :criteria_is_from_grant

  validate :score_if_mandatory,   if: -> { criterion.is_mandatory? }

  validate :comment_if_not_shown, unless: -> { criterion.show_comment_field? }

  scope :by_criterion,  -> (criterion)  { where(criterion: criterion.id) }
  scope :by_submission, -> (submission) { joins(:submission).where('grant_submission_submission_id = ?', submission.id) }
  scope :scored,        -> { where.not(score: nil) }

  private

  def criteria_is_from_grant
    errors.add(:base, :criteria_not_from_grant, criterion: criterion.name, criterion_id: criterion.id) if grant.criteria.exclude?(criterion)
  end

  def score_if_mandatory
    errors.add(:base, :required_score, criterion: criterion.name) if score.blank?
  end

  def comment_if_not_shown
    errors.add(:base, :comment_not_shown, criterion: criterion.name) unless comment.blank?
  end
end
