module GrantSubmission
  class Submission < ApplicationRecord
    include WithScoring

    self.table_name = 'grant_submission_submissions'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SubmissionVersion' },
                    meta: { grant_id: :grant_id, applicant_id: :created_id }

    ransack_alias :applicant, :applicant_first_name_or_applicant_last_name_cont

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

    validates_presence_of :title
    validates_presence_of :form

    # scope :eager_loading,         -> {includes({:responses => [:question]}, :children)}

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
      reviews.pluck(:overal_impact_score)
    end
  end
end
