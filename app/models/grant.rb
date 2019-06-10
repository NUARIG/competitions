# frozen_string_literal: true

class Grant < ApplicationRecord
  include ActiveModel::Validations::Callbacks
  include SoftDeletable
  extend FriendlyId
  friendly_id :slug

  attr_accessor :duplicate

  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }

  belongs_to :organization
  has_many   :grant_permissions
  has_many   :users,            through: :grant_permissions
  has_one    :form,             class_name: 'GrantSubmission::Form',
                                foreign_key: :grant_id
  has_many   :submissions,      class_name: 'GrantSubmission::Submission',
                                foreign_key: :grant_id,
                                dependent: :destroy

  SLUG_MIN_LENGTH = 3
  SLUG_MAX_LENGTH = 15

  GRANT_STATES    = { demo:      'demo',      # TODO: define specifics of each
                      draft:     'draft',
                      published: 'published', # e.g. can be opened and may be in process
                      completed: 'completed'  # e.g. awarded and closed
                     }.freeze


  SOFT_DELETABLE_STATES = %w[demo draft]

  enum state: GRANT_STATES

  before_destroy    :deletable?
  before_validation :prepare_slug, if: -> { slug.present? }
  before_validation :set_default_state, if: :new_record?

  validates_presence_of :name,
                        :slug,
                        :submission_open_date,
                        :submission_close_date,
                        :publish_date

  validates_format_of :slug,
                      with: /\A[a-z0-9]+(?:[-|_][a-z0-9]+)*\z/i,
                      message: 'may only include letters, numbers, dashes and underscores.'
  validates_format_of :slug,
                      with: /[a-z]{1,}/i,
                      message: 'must include at least one letter.'

  validates_inclusion_of :state, in: GRANT_STATES.values,
                                 message: 'is not a valid state.'


  validates_length_of :slug, in: Grant::SLUG_MIN_LENGTH..Grant::SLUG_MAX_LENGTH

  validates_numericality_of :max_reviewers_per_proposal,
                            only_integer: true,
                            greater_than_or_equal_to: 1,
                            if: :max_reviewers_per_proposal?

  validates_numericality_of :max_proposals_per_reviewer,
                            only_integer: true,
                            greater_than_or_equal_to: 1,
                            if: :max_proposals_per_reviewer?

  validates_uniqueness_of :name
  validates_uniqueness_of :slug, case_sensitive: false

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

  def is_soft_deletable?
    SOFT_DELETABLE_STATES.include?(state) ? true : send("#{state}_soft_deletable_error")
  end

  def is_open?
    DateTime.now >= submission_open_date.beginning_of_day
  end

  def accepting_submissions?
    published? && DateTime.now.between?(submission_open_date.beginning_of_day,
                                        submission_close_date.end_of_day)
  end

  private

  def set_default_state
    self.state ||= Grant::GRANT_STATES[:draft]
  end

  def deletable?
    # TODO: Review destroy / soft delete logic as other models are added
    raise SoftDeleteException.new('Grants must be soft deleted.')
  end

  def prepare_slug
    slug.strip!
  end

  # TODO: Should these two be boolians that then spit out a result
  def published_soft_deletable_error
    raise SoftDeleteException.new('Published grant may not be deleted')
  end

  def completed_soft_deletable_error
    raise SoftDeleteException.new('Completed grant may not be deleted')
  end

  def process_association_soft_delete
    ActiveRecord::Base.transaction do
      # TODO: determine whether any/all of these should these be called
      # grant_permissions.update_all(deleted_at: Time.now)
      #       reviews
      #       reviewers
      #       panel
    end
  end
end
