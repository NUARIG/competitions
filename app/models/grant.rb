# frozen_string_literal: true

class Grant < ApplicationRecord
  include SoftDeletable

  attr_accessor :default_set, :duplicate

  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }

  belongs_to  :organization
  has_many    :questions
  has_many    :grant_users
  has_many    :users, through: :grant_users

  accepts_nested_attributes_for :questions

  GRANT_STATES = { demo:      'demo',      # TODO: define specifics of each
                   draft:     'draft',
                   published: 'published', # e.g. can be opened and may be in process
                   completed: 'completed'  # e.g. awarded and closed
                 }.freeze

  SOFT_DELETABLE_STATES = %w[demo draft]

  enum state: GRANT_STATES

  validates_presence_of :name
  validates_presence_of :submission_open_date
  validates_presence_of :submission_close_date
  validates_presence_of :publish_date

  validates_date :publish_date,
                 on: :create,
                 on_or_after: :today,
                 on_or_after_message: 'cannot be earlier than today.'
  validates_date :submission_open_date,
                 on: %i[create update],
                 on_or_after: :publish_date,
                 on_or_after_message: 'cannot be earlier than the publish date.'
  validates_date :submission_close_date,
                 after: :submission_open_date,
                 after_message: 'must be after the opening date for submissions.'
  validates_date :review_open_date,
                 after: :submission_open_date,
                 after_message: 'must be after the submission open date.'
  validates_date :review_close_date,
                 after: :review_open_date,
                 after_message: 'must be after the review opening date.'
  validates_date :panel_date,
                 after: :submission_close_date,
                 after_message: 'must be after the submission close date.',
                 if: :panel_date?

  validates :name, uniqueness: true
  validates :short_name,
            presence: true, if: -> { name.present? && name.length > 10 },
            length: { minimum: 3, maximum: 10 },
            uniqueness: true

  validates :max_reviewers_per_proposal,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 },
            if: :max_reviewers_per_proposal?
  validates :max_proposals_per_reviewer,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 },
            if: :max_proposals_per_reviewer?

  validate :valid_default_set, on: :create, unless: -> { duplicate.present? }

  before_destroy :deletable?

  scope :public_grants,      -> { not_deleted.
                                    published.
                                    where(':date BETWEEN
                                                   publish_date
                                                 AND
                                                   submission_close_date',
                                          date: Date.current).
                                    by_publish_date }
  scope :by_publish_date,    -> { order(publish_date: :asc) }
  scope :with_organization,  -> { joins(:organization) }
  scope :with_questions,     -> { includes :questions }

  def is_soft_deletable?
    SOFT_DELETABLE_STATES.include?(state) ? true : send("#{state}_soft_deletable?")
  end

  def accepting_submissions?
    published? && DateTime.now.between?(submission_open_date.beginning_of_day,
                                        submission_close_date.end_of_day)
  end

  private

  def deletable?
    # TODO: Review destroy / soft delete logic as other models are added
    raise SoftDeleteException.new('Grants must be soft deleted.')
  end

  def valid_default_set
    errors.add(:base, 'Please choose a default question set') unless DefaultSet.where(id: default_set).exists?
  end

  def published_soft_deletable?
    # TODO: e.g. submissions.count.zero?
    raise SoftDeleteException.new('Published grant may not be deleted')
  end

  def completed_soft_deletable?
    raise SoftDeleteException.new('Completed grant may not be deleted')
  end

  def process_association_soft_delete
    ActiveRecord::Base.transaction do
      # TODO: determine whether any/all of these should these be called
      # grant_users.update_all(deleted_at: Time.now)
      # questions.update_all(deleted_at: Time.now)
      # constraint_questions
      #       submissions
      #       reviews
      #       reviewers
      #       panel
    end
  end
end
