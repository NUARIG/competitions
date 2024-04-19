class Review < ApplicationRecord
  include WithScoring
  include Discard::Model
  
  attr_accessor :user_submitted_state
  
  after_validation :set_state, on: :update,
                               if: -> { user_submitted_state.present?  }

  REVIEW_STATES = { assigned: 'assigned',
                    draft: 'draft',
                    submitted: 'submitted' }.freeze

  enum state: REVIEW_STATES, _default: 'assigned'

  after_commit     :update_submission_averages, on: %i[create update destroy]
  after_touch      :update_submission_averages

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
  has_one  :submitter,        through: :submission
  has_one  :grant,            through: :submission
  has_many :grant_criteria,   through: :grant,
                              source: :criteria
  has_many :applicants,       through: :submission

  has_many :criteria_reviews, -> { order("criteria_reviews.created_at") },
                              dependent: :destroy,
                              inverse_of: :review
  has_many :criteria,         through: :criteria_reviews

  accepts_nested_attributes_for :criteria_reviews
  validates_associated :criteria_reviews, on: :update, 
                                          if: -> { self.submitted? || self.user_submitted_state == REVIEW_STATES[:submitted] }
  
  # validates_presence_of     :reviewer
  validates_presence_of     :overall_impact_score, if: -> { self.submitted? }

  validates_uniqueness_of   :reviewer, scope: :submission

  validates_numericality_of :overall_impact_score, only_integer: true,
                                                   greater_than_or_equal_to: MINIMUM_ALLOWED_SCORE,
                                                   less_than_or_equal_to: MAXIMUM_ALLOWED_SCORE,
                                                   if: -> { overall_impact_score.present? && !self.state != REVIEW_STATES[:assigned] }

  validate :reviewer_is_a_grant_reviewer, if: -> { self.reviewer.present? }
  validate :assigner_is_a_grant_editor
  validate :reviewer_is_not_applicant
  validate :reviewer_may_be_assigned,       if: -> { self.new_record? && reviewer.present? } 
  validate :reviewer_may_not_be_reassigned, on: :update,
                                            if: :reviewer_id_changed?
  validate :submission_is_not_draft
  validate :is_not_after_close_date
  
  scope :with_criteria_reviews,                   -> { includes(:criteria_reviews) }
  scope :with_reviewer,                           -> { includes(:reviewer) }
  scope :with_grant,                              -> { includes(submission: :grant) }
  scope :with_grant_and_submitter_and_applicants, -> { includes(submission: [:grant, :submitter, :applicants]) }
  scope :by_grant,                                -> (grant) { with_grant.where(grants: { id: grant.id}) }

  scope :order_by_created_at,                     -> { order(created_at: :desc) }
  scope :by_reviewer,                             -> (reviewer)   { where(reviewer_id: reviewer.id) }
  scope :by_submission,                           -> (submission) { where(grant_submission_submission_id: submission.id) }
  # legacy methods
  scope :completed,                               -> { submitted }
  scope :incomplete,                              -> { where(state: %w[draft assigned]) }
  # TODO: could be used to throttle reminders to a given timeframe
  # scope :may_be_reminded,          -> { incomplete.where("reminded_at IS NULL OR reminded_at < ?", 1.week.ago) }

  def is_complete?
    submitted? || self.user_submitted_state == REVIEW_STATES[:submitted]
  end

  def scored_criteria_scores
    criteria_reviews.scored.pluck(:score)
  end

  def composite_score
    calculate_average_score(scored_criteria_scores)
  end

  def update_submission_averages
    submission.set_composite_score
    submission.set_average_overall_impact_score
  end

  def review_period_closed?
    # TODO: enforce grant.review_open_date ?
    Time.now > grant.review_close_date.end_of_day
  end

  private

  def reviewer_is_a_grant_reviewer
    errors.add(:reviewer, :is_not_a_reviewer) unless grant.reviewers.include?(reviewer)
  end

  def assigner_is_a_grant_editor
    errors.add(:assigner, :may_not_add_review) unless Pundit.policy(assigner, grant).grant_editor_access?
  end

  def reviewer_is_not_applicant
    errors.add(:reviewer, :may_not_review_own_submission) if submission.has_applicant?(reviewer)
  end

  def reviewer_may_be_assigned
    errors.add(:reviewer, :has_reached_review_limit) unless reviewer.reviewable_submissions.by_grant(grant).count < grant.max_submissions_per_reviewer
  end

  def reviewer_may_not_be_reassigned
    errors.add(:reviewer, :may_not_be_reassigned)
  end

  def submission_is_not_draft
    errors.add(:submission, :may_not_be_draft) if submission.draft?
  end

  def is_not_after_close_date
    errors.add(:base, :may_not_review_after_close_date, review_close_date: I18n.l(grant.review_close_date)) if review_period_closed?
  end

  def set_state
    self.state = user_submitted_state
  end
end
