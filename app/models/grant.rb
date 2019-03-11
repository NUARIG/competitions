class Grant < ApplicationRecord

  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }

  belongs_to  :organization
  has_many    :questions, dependent: :destroy
  has_many    :grant_users
  has_many    :users, through: :grant_users

  accepts_nested_attributes_for :questions

  enum state: {
    demo: 'demo',
    draft: 'draft',
    complete: 'complete'
  }

  validates_presence_of :name
  validates_presence_of :submission_open_date
  validates_presence_of :submission_close_date
  validates_presence_of :panel_location, if: :panel_date?
  validates_presence_of :initiation_date

  validates_date :initiation_date, on_or_after: :today
  validates_date :submission_open_date,
                    { on_or_after: :initiation_date,
                      message: 'cannot be earlier than the initiation date.' }
  validates_date :submission_close_date,
                    { after: :submission_open_date,
                      message: 'must be after the opening date for submissions.' }
  validates_date :review_open_date,
                    { after: :submission_open_date,
                      message: 'must be after the submission open.' }
  validates_date :review_close_date,
                    { after: :review_open_date,
                      message: 'must be after the review opening date.' }
  validates_date :panel_date,
                    { after: :submission_close_date,
                      message: 'must be after the submission_close_date',
                      if: :panel_date? }

  validates :name, uniqueness: true
  validates :short_name,
    presence: true, if: -> { name.present? && name.length > 10 },
    length: { minimum: 3, maximum: 10 },
    uniqueness: true

  validates :min_budget, numericality: { greater_than_or_equal_to: 0 }
  validates :max_budget, numericality: { greater_than: :min_budget,
                                         if: :min_budget? }

  validates :max_reviewers_per_proposal,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :max_proposals_per_reviewer,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validates :panel_location, presence: true, if: :panel_date?

  scope :by_initiation_date, -> { order(initiation_date: :asc) }
  scope :with_organization,  -> { joins(:organization) }
  scope :with_questions,     -> { includes :questions }

end
