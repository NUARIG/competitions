class Review < ApplicationRecord
  include WithScoring
  include Discard::Model

  has_paper_trail versions: { class_name: 'PaperTrail::ReviewVersion' },
                  meta:     { grant_id: proc { |review| review.grant.id }, reviewer_id: :reviewer_id }

  belongs_to :assigner,       class_name: 'User',
                              foreign_key: 'assigner_id'
  belongs_to :reviewer,       class_name: 'User',
                              foreign_key: 'reviewer_id'
  belongs_to :submission,     class_name: 'GrantSubmission::Submission',
                              foreign_key: 'grant_submission_submission_id',
                              counter_cache: true,
                              inverse_of: :reviews
  has_one  :applicant,        through: :submission
  has_one  :grant,            through: :submission
  has_many :grant_criteria,   through: :grant,
                              source: :criteria

  has_many :criteria_reviews, -> { order("criteria_reviews.created_at") },
                              dependent: :destroy
  has_many :criteria,         through: :criteria_reviews

  accepts_nested_attributes_for :criteria_reviews

  validates_presence_of     :reviewer
  validates_presence_of     :overall_impact_score, unless: :new_record?

  validates_uniqueness_of   :reviewer, scope: :submission

  validates_numericality_of :overall_impact_score, only_integer: true,
                                                   greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                                   less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE,
                                                   unless: :new_record?

  validate :reviewer_is_a_grant_reviewer
  validate :assigner_is_a_grant_editor
  validate :reviewer_is_not_applicant
  validate :reviewer_may_be_assigned,       if: :new_record?
  validate :reviewer_may_not_be_reassigned, on: :update,
                                            if: :reviewer_id_changed?

  scope :with_criteria_reviews,    -> { includes(:criteria_reviews) }
  scope :with_reviewer,            -> { includes(:reviewer) }
  scope :with_grant,               -> { includes(submission: :grant) }
  scope :with_grant_and_applicant, -> { includes(submission: [:grant, :applicant]) }
  scope :by_grant,                 -> (grant) { with_grant.where(grants: { id: grant.id}) }

  scope :order_by_created_at,      -> { order(created_at: :desc) }
  scope :by_reviewer,              -> (reviewer)   { where(reviewer_id: reviewer.id) }
  scope :by_submission,            -> (submission) { where(grant_submission_submission_id: submission.id) }
  scope :completed,                -> { where.not(overall_impact_score: nil)}
  scope :incomplete,               -> { where(overall_impact_score: nil)}

  def is_complete?
    !overall_impact_score.nil?
  end

  def scored_criteria_scores
    criteria_reviews.scored.pluck(:score)
  end

  def composite_score
    calculate_average_score(scored_criteria_scores)
  end

  private

  def reviewer_is_a_grant_reviewer
    errors.add(:reviewer, :is_not_a_reviewer) unless grant.reviewers.include?(reviewer)
  end

  def assigner_is_a_grant_editor
    errors.add(:assigner, :may_not_add_review) unless Pundit.policy(assigner, grant).grant_editor_access?
  end

  def reviewer_is_not_applicant
    errors.add(:reviewer, :may_not_review_own_submission) if reviewer == submission.applicant
  end

  def reviewer_may_be_assigned
    errors.add(:reviewer, :has_reached_review_limit) unless reviewer.reviewable_submissions.by_grant(grant).count < grant.max_submissions_per_reviewer
  end

  def reviewer_may_not_be_reassigned
    errors.add(:reviewer, :may_not_be_reassigned)
  end

  # TODO: use this for every review load?
  # after_initialize :define_criteria_reviews

  # def define_criteria_reviews
  #   submission.grant.criteria.each do |criterion|
  #     unless self.criteria_reviews.detect{ |cr| cr.criterion_id == criterion.id }.present?
  #       self.criteria_reviews.build(criterion: criterion, review: self)
  #     end
  #   end
  # end
end
