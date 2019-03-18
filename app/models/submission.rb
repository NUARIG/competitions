class Submission < ApplicationRecord
 #  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }

  belongs_to  :user
  belongs_to  :grant
  # has_many    :responses
  # has_many    :panel_score
  # has_many    :reviews

  after_initialize :set_default_state, if: :new_record?

  enum state: {
    demo: 'demo',
    draft: 'draft',
    complete: 'complete'
  }.freeze

  validates_presence_of :user
  validates_presence_of :grant
  validates_presence_of :project_title
  validates_presence_of :state


  # validates_date :review_close_date,
  #                  after: :review_open_date,
  #                  message: 'must be after the review opening date.'

  scope :by_creation_time,          -> { order(created_at: :asc) }
  scope :with_grant,                -> { includes :grants }
  scope :with_grant_and_questions,  -> { includes(:grant).merge(Grant.with_questions) }
  # scope :with_grant_questions_and_constraints,  -> { includes(:grant).merge(Grant.with_questions).merge(Question.with_constraints_and_constraint_questions) }

  private

  def set_default_state
    self.state ||= :draft
  end
end
