module GrantSubmission
  class Submission < ApplicationRecord
    include WithScoring
    include Discard::Model

    attr_accessor :user_submitted_state

    after_validation :set_state, on: %i[create update],
                                 if: -> { user_submitted_state.present? && errors.none? }
    before_destroy :abort_or_prepare_destroy, prepend: true

    self.table_name = 'grant_submission_submissions'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SubmissionVersion' },
                    meta: { grant_id: :grant_id, submitter_id: :created_id }

    belongs_to :grant,                inverse_of: :submissions
    belongs_to :form,                 class_name: 'GrantSubmission::Form',
                                      foreign_key: 'grant_submission_form_id',
                                      inverse_of: :submissions
    has_many :sections,               through: :form
    belongs_to :submitter,            class_name: 'User',
                                      foreign_key: 'created_id'
    has_many :submission_applicants,  dependent: :delete_all, # This does not trigger callbacks on the children, so it will not delete any grandchildren if added in the future.
                                      class_name: 'GrantSubmission::SubmissionApplicant',
                                      foreign_key: 'grant_submission_submission_id',
                                      inverse_of: :submission
    has_many :applicants,             through: :submission_applicants,
                                      class_name: 'User',
                                      foreign_key: :applicant_id

    has_many :responses,              dependent: :destroy,
                                      class_name: 'GrantSubmission::Response',
                                      foreign_key: 'grant_submission_submission_id',
                                      inverse_of: :submission
    has_many :reviews,                foreign_key: 'grant_submission_submission_id',
                                      inverse_of: :submission
    has_many :reviewers,              through: :reviews,
                                      source: :reviewer
    has_many :criteria_reviews,       through: :reviews,
                                      inverse_of: :submission

    accepts_nested_attributes_for :responses, allow_destroy: true
    accepts_nested_attributes_for :submission_applicants, allow_destroy: true

    SUBMISSION_STATES = { draft: 'draft',
                          submitted: 'submitted' }.freeze

    enum state: SUBMISSION_STATES

    validates :title, presence: true
    validates :form, presence: true

    validates_associated :responses

    validate :can_be_unsubmitted?, on: :update,
                                   if: -> () { will_save_change_to_attribute?('state', from: SUBMISSION_STATES[:submitted],
                                                                                       to: SUBMISSION_STATES[:draft]) }
    validate :can_be_awarded?, if: -> () { will_save_change_to_attribute?('awarded', to: true) }

    scope :with_responses,      -> { includes( form: [sections: [questions: [responses: :multiple_choice_option]]] ) }
    scope :order_by_created_at, -> { order(created_at: :desc) }
    scope :by_grant,            -> (grant) { where(grant_id: grant.id) }
    scope :to_be_assigned,      -> (max) { where(["reviews_count < ?", max]) }
    scope :with_reviews,        -> { includes(reviews: [:reviewer, :criteria_reviews]) }
    scope :with_reviewers,      -> { includes(:reviewers) }
    scope :with_submitter,      -> { includes(:submitter) }
    scope :with_applicants,     -> { includes(:applicants) }

    scope :sort_by_average_overall_impact_score_nulls_last_asc,  -> { order(Arel.sql("average_overall_impact_score = 0 nulls last, average_overall_impact_score ASC NULLS LAST")) }
    scope :sort_by_average_overall_impact_score_nulls_last_desc, -> { order(Arel.sql("average_overall_impact_score = 0 nulls last, average_overall_impact_score DESC NULLS LAST")) }

    scope :sort_by_composite_score_nulls_last_asc,  -> { order(Arel.sql("composite_score = 0 nulls last, composite_score ASC")) }
    scope :sort_by_composite_score_nulls_last_desc, -> { order(Arel.sql("composite_score = 0 nulls last, composite_score DESC")) }

    scope :reviewed, -> { where("average_overall_impact_score > 0") }

    # TODO: available? to...edit? delete?
    def available?
      return true
      # TODO: Figure out policies
      #       HIGH PRIORITY
      # is_root? ? super : parent.available?
    end

    # CALLBACKS
    def abort_or_prepare_destroy
      if may_be_deleted?
        prepare_submission_destroy
      else
        prevent_delete_from_published_grant
        throw(:abort)
      end
    end

    # REVIEWS
    def set_average_overall_impact_score
      self.update(average_overall_impact_score: calculate_average_score(reviews.submitted.map(&:overall_impact_score)))
    end

    def set_composite_score
      self.update(composite_score: calculate_average_score(get_submitted_criteria_reviews.flat_map(&:score)))
    end

    def available_for_review_assignment?
      self.reviews.length < grant.max_reviewers_per_submission
    end

    # USERS
    def has_applicant?(user)
      applicants.include?(user)
    end

    def eligible_reviewers
      return nil if reviews.length >= grant.max_reviewers_per_submission || self.draft?
      
      review_count_limit = grant.max_submissions_per_reviewer 
      submission_review_count_limit = grant.max_reviewers_per_submission 

      # Get all submissions and their reviews, 
      #  tally's each reviewer's count of assigned reviews
      #  filters out reviewers with review_count_limit number of 
      already_maxed_out_reviewers = GrantSubmission::Submission
                                      .with_reviewers
                                      .by_grant(grant)
                                      .flat_map(&:reviewers)
                                      .tally
                                      .filter{ |reviewer, review_count| review_count == review_count_limit }
                                      .keys

      return (grant.grant_reviewers.map(&:reviewer) - (already_maxed_out_reviewers + self.applicants + self.reviewers).uniq)
    end

    private

    def set_state
      # self.update(state: user_submitted_state)
      self.state = user_submitted_state
    end

    def can_be_unsubmitted?
      errors.add(:base, :reviewed_submission_cannot_be_unsubmitted) if self.reviews.completed.any?
    end

    def can_be_awarded?
      return errors.add(:base, :draft_submission_cannot_be_awarded) if self.state == 'draft'
      return errors.add(:base, :unreviewed_submission_cannot_be_awarded) unless self.average_overall_impact_score&.nonzero?
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

    def get_submitted_criteria_reviews
      self.reviews.submitted.flat_map(&:criteria_reviews)
    end

    def may_be_deleted?
      grant.draft? || submitter.in?(grant.admins)
    end
  end
end
