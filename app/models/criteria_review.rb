class CriteriaReview < ApplicationRecord
  include WithScoring
  has_paper_trail versions: { class_name: 'PaperTrail::CriteriaReviewVersion' },
                  meta:     { review_id: :review_id }

  belongs_to :criterion
  belongs_to :review

  has_one :submission, through: :review

  validates_numericality_of :score, only_integer: true,
                                    unless: -> { score.blank? }
  validates_numericality_of :score, greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? }
  validates_numericality_of :score, less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE,
                                    unless: -> { score.blank? }

  validate :score_if_mandatory,   if: -> { criterion.is_mandatory? }
  validate :comment_if_not_shown, unless: -> { criterion.show_comment_field? }

  scope :by_criterion,  -> (criterion)  { where(criterion: criterion.id) }
  scope :by_submission, -> (submission) { joins(:submission).where('grant_submission_submission_id = ?', submission.id) }
  scope :scored,        -> { where.not(score: nil) }

  private

  def score_if_mandatory
    errors.add(:base, :required_score, criterion: criterion.name) if score.blank?
  end

  def comment_if_not_shown
    errors.add(:base, :comment_not_shown, criterion: criterion.name) unless comment.blank?
  end
end
