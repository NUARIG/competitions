module GrantSubmission
  class Submission < ApplicationRecord
    include WithScoring
    include Discard::Model

    self.table_name = 'grant_submission_submissions'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SubmissionVersion' },
                    meta: { grant_id: :grant_id, applicant_id: :created_id }

    belongs_to :grant,          inverse_of: :submissions
    belongs_to :form,           class_name: 'GrantSubmission::Form',
                                foreign_key: 'grant_submission_form_id',
                                inverse_of: :submissions
    belongs_to :applicant,      class_name: 'User',
                                foreign_key: 'created_id'
    has_many :responses,        dependent: :destroy,
                                class_name: 'GrantSubmission::Response',
                                foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    has_many :reviews,          dependent: :destroy,
                                foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    has_many :reviewers,        through: :reviews,
                                source: :reviewer
    has_many :criteria_reviews, through: :reviews


    accepts_nested_attributes_for :responses, allow_destroy: true



    SUBMISSION_STATES     = { draft:     'draft',
                              submitted: 'submitted'
                            }.freeze

    enum state: SUBMISSION_STATES

    validates :title, presence: true
    validates :form, presence: true

    validates_associated :responses, if: -> { self.submitted? }

    validate :can_be_unsubmitted?, on: :update,
                                   if: -> () { will_save_change_to_attribute?('state', from: SUBMISSION_STATES[:submitted],
                                                                                       to: SUBMISSION_STATES[:draft]) }

    scope :eager_loading,       -> {includes({:responses => [:question]}, :children)}

    scope :order_by_created_at, -> { order(created_at: :desc) }
    scope :by_grant,            -> (grant) { where(grant_id: grant.id) }
    scope :to_be_assigned,      -> (max) { where(["reviews_count < ?", max]) }
    scope :with_reviews,        -> { includes( reviews: [:reviewer, :criteria_reviews]) }
    scope :with_reviewers,      -> { includes( :reviewers ) }
    scope :with_applicant,      -> { includes( :applicant ) }

    # TODO: available? to...edit? delete?
    def available?
      return true
      # TODO: Figure out policies
      #       HIGH PRIORITY
      # is_root? ? super : parent.available?
    end

    # REVIEWS
    def all_scored_criteria
      criteria_reviews.scored.pluck(:score)
    end

    def scores_by_criterion(criterion)
      criteria_reviews.by_criterion(criterion).pluck(:score)
    end

    def overall_impact_scores
      reviews.pluck(:overall_impact_score)
    end

    private

    def can_be_unsubmitted?
      errors.add(:base, :reviewed_submission_cannot_be_unsubmitted) if self.reviews.completed.any?
    end
  end
end
