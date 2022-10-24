# frozen_string_literal: true

class Grant < ApplicationRecord
  include ActiveModel::Validations::Callbacks

  extend FriendlyId
  has_paper_trail versions: { class_name: 'PaperTrail::GrantVersion' }
  friendly_id :slug

  include Discard::Model

  after_discard do
    panel.discard
    submissions.discard_all
    reviews.discard_all
  end

  after_undiscard do
    panel.undiscard
    submissions.undiscard_all
    reviews.undiscard_all
  end

  attr_accessor :duplicate

  attribute :max_reviewers_per_submission, :integer, default: 2
  attribute :max_submissions_per_reviewer, :integer, default: 2

  has_one_attached :document

  has_one    :form,                 class_name: 'GrantSubmission::Form',
                                    foreign_key: :grant_id
  has_one    :panel,                foreign_key: :grant_id
  has_many   :grant_reviewers
  has_many   :reviewers,            through: :grant_reviewers
  has_many   :reviewer_invitations, class_name: 'GrantReviewer::Invitation'

  has_many   :grant_permissions
  has_many   :contacts,             -> { with_user.contacts }, class_name: 'GrantPermission'
  has_many   :administrators,       through: :grant_permissions,
                                    source: :user

  has_many   :questions,            through: :form

  has_many   :submissions,          class_name:   'GrantSubmission::Submission',
                                    foreign_key:  :grant_id,
                                    inverse_of:   :grant,
                                    dependent:    :destroy

  has_many   :reviews,              through: :submissions

  has_many   :submitters,           through: :submissions

  has_many   :applicants,           class_name: 'User',
                                    inverse_of: :applied_grants,
                                    through:    :submissions


  has_many   :criteria,             inverse_of: :grant

  accepts_nested_attributes_for :criteria, allow_destroy: true

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

  validates_numericality_of :max_reviewers_per_submission,
                            only_integer: true,
                            greater_than_or_equal_to: 1

  validates_numericality_of :max_submissions_per_reviewer,
                            only_integer: true,
                            greater_than_or_equal_to: 1

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

  validate      :requires_one_criteria,      on: :update,
                                             if: -> () { criteria.all?(&:marked_for_destruction?) || criteria.empty? }

  validate      :has_at_least_one_question?, on: :update,
                                             if: -> () { will_save_change_to_attribute?('state', to: 'published') }

  validate      :is_discardable?,            on: :discard

  scope :public_grants,      -> { undiscarded.
                                    published.
                                    where(':date BETWEEN
                                                   publish_date
                                                 AND
                                                   submission_close_date',
                                          date: Date.current).
                                    by_publish_date }
  scope :by_publish_date,     -> { order(publish_date: :asc) }
  scope :with_criteria,       -> { includes(:criteria) }
  scope :unassigned_submissions, lambda { |*args| where('submission_reviews_count < :max_reviewers', { :max_reviewers => args.first || 2 }) }
  scope :with_reviewers,      -> { includes(:reviewers) }
  scope :with_reviews,        -> { includes(:reviews) }
  scope :with_panel,          -> { includes(:panel) }
  scope :with_administrators, -> { includes(:administrators) }

  def is_discardable?
    SOFT_DELETABLE_STATES.include?(state) ? true : send("#{state}_discardable?")
  end

  def is_open?
    DateTime.now.between?(submission_open_date.beginning_of_day,
                          submission_close_date.end_of_day)
  end

  def accepting_submissions?
    published? && is_open?
  end

  def requires_one_criteria
    criteria.each { |c| c.reload if c.marked_for_destruction? }
    errors.add(:base, 'Must have at least one review criteria.')
  end

  # def admins, def editors, def viewers
  GrantPermission::ROLES.each do |_,role|
    define_method "#{role.pluralize}".to_sym do
      grant_permissions.send("role_#{role}").to_a.map(&:user)
    end
  end

  private

  def set_default_state
    self.state ||= Grant::GRANT_STATES[:draft]
  end

  def prepare_slug
    slug.strip!
  end

  def deletable?
    raise SoftDeleteException.new('Grants must be discarded.')
  end

  def published_discardable?
    # TODO: e.g. submissions.count.zero?
    errors.add(:base, 'Published grant may not be deleted.')
    return false
  end

  def completed_discardable?
    # TODO: this state is not active
    errors.add(:base, 'Completed grant may not be deleted.')
    return false
  end

  def has_at_least_one_question?
    errors.add(:base, 'A question is required before a grant can be published.') unless questions.any?
  end
end
