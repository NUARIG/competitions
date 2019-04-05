class Submission < ApplicationRecord
 #  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }

  belongs_to  :user
  belongs_to  :grant
  # has_many    :responses
  # has_many    :panel_score
  # has_many    :reviews

  after_initialize :set_default_state, if: :new_record?

  enum state: {
    draft: 'draft',
    submitted: 'submitted'
  }.freeze

  validates_presence_of :user
  validates_presence_of :grant
  validates_presence_of :project_title
  validates_presence_of :state

  validate :within_submission_dates, if: -> { grant.present? }

  scope :by_creation_time,          -> { order(created_at: :asc) }
  scope :with_grant,                -> { includes :grants }
  scope :with_grant_and_questions,  -> { includes(:grant).merge(Grant.with_questions) }
  # scope :with_grant_questions_and_constraints,  -> { includes(:grant).merge(Grant.with_questions).merge(Question.with_constraints_and_constraint_questions) }

  private
  def within_submission_dates
    errors.add(:base, 'The competition is not open.') unless DateTime.now.between?(self.grant.submission_open_date, self.grant.submission_close_date)
  end

  def set_default_state
    self.state ||= :draft
  end
end
