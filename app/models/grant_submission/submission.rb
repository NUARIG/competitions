module GrantSubmission
  class Submission < ApplicationRecord
    include WithScoring
    include Discard::Model

    attr_accessor :user_submitted_state
    after_validation :set_state, on: [:create, :update],
                                 if: -> { user_submitted_state.present? && errors.none? }
    before_destroy :abort_or_prepare_destroy, prepend: true

    self.table_name = 'grant_submission_submissions'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SubmissionVersion' },
                    meta: { grant_id: :grant_id, submitter_id: :created_id }

    belongs_to :grant,          inverse_of: :submissions
    belongs_to :form,           class_name: 'GrantSubmission::Form',
                                foreign_key: 'grant_submission_form_id',
                                inverse_of: :submissions
    has_many :sections,         through: :form
    belongs_to :submitter,      class_name: 'User',
                                foreign_key: 'created_id'
    has_many :permissions,      class_name: 'GrantSubmission::Permission',
                                foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    has_many :users,            through: :permissions

    has_many :responses,        dependent: :destroy,
                                class_name: 'GrantSubmission::Response',
                                foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    has_many :reviews,          foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    has_many :reviewers,        through: :reviews,
                                source: :reviewer
    has_many :criteria_reviews, through: :reviews,
                                inverse_of: :submission


    accepts_nested_attributes_for :responses, allow_destroy: true

    SUBMISSION_STATES     = { draft:     'draft',
                              submitted: 'submitted'}.freeze

    enum state: SUBMISSION_STATES

    validates :title, presence: true
    validates :form, presence: true

    validates_associated :responses

    validate :can_be_unsubmitted?, on: :update,
                                   if: -> () { will_save_change_to_attribute?('state', from: SUBMISSION_STATES[:submitted],
                                                                                       to: SUBMISSION_STATES[:draft]) }

    scope :with_responses,      -> { includes( form: [sections: [questions: [responses: :multiple_choice_option]]] ) }

    scope :order_by_created_at, -> { order(created_at: :desc) }
    scope :by_grant,            -> (grant) { where(grant_id: grant.id) }
    scope :to_be_assigned,      -> (max) { where(["reviews_count < ?", max]) }
    scope :with_reviews,        -> { includes( reviews: [:reviewer, :criteria_reviews]) }
    scope :with_reviewers,      -> { includes( :reviewers ) }
    scope :with_submitter,      -> { includes( :submitter ) }

    scope :sort_by_average_overall_impact_score_nulls_last_asc,  -> { order(Arel.sql("average_overall_impact_score = 0 nulls last, average_overall_impact_score ASC NULLS LAST")) }
    scope :sort_by_average_overall_impact_score_nulls_last_desc, -> { order(Arel.sql("average_overall_impact_score = 0 nulls last, average_overall_impact_score DESC NULLS LAST")) }

    scope :sort_by_composite_score_nulls_last_asc,  -> { order(Arel.sql("composite_score = 0 nulls last, composite_score ASC")) }
    scope :sort_by_composite_score_nulls_last_desc, -> { order(Arel.sql("composite_score = 0 nulls last, composite_score DESC")) }

    scope :reviewed,            -> { where("average_overall_impact_score > 0") }

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

    def set_average_overall_impact_score
      self.update(average_overall_impact_score: calculate_average_score(reviews.to_a.map(&:overall_impact_score)))
    end

    def set_composite_score
      self.update(composite_score: calculate_average_score(self.criteria_reviews.to_a.map(&:score)))
    end

    def abort_or_prepare_destroy
      if self.grant.published?
        prevent_delete_from_published_grant
        throw(:abort)
      else
        prepare_submission_destroy
      end
    end

    private

    def set_state
      # self.update(state: user_submitted_state)
      self.state = user_submitted_state
    end

    def can_be_unsubmitted?
      errors.add(:base, :reviewed_submission_cannot_be_unsubmitted) if self.reviews.completed.any?
    end

    def prevent_delete_from_published_grant
      errors.add(:base, :may_not_delete_from_published_grant)
    end

    def prepare_submission_destroy
      # bypasses Review recalculate score callbacks
      #   to avoid "can't modify frozen hash" error
      self.reviews.each do |review|
        review.criteria_reviews.destroy_all
        review.delete
      end
    end
  end
end
