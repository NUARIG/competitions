module GrantSubmission
  class Submission < ApplicationRecord
    include WithScoring

    self.table_name = 'grant_submission_submissions'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SubmissionVersion' },
                    meta: { grant_id: :grant_id, applicant_id: :created_id }

    belongs_to :grant,          inverse_of: :submissions
    belongs_to :form,           class_name: 'GrantSubmission::Form',
                                foreign_key: 'grant_submission_form_id',
                                inverse_of: :submissions
    belongs_to :section,        class_name: 'GrantSubmission::Section',
                                foreign_key: 'grant_submission_section_id',
                                optional: true
    belongs_to :applicant,      class_name: 'User',
                                foreign_key: 'created_id'
    has_many :responses,        dependent: :destroy,
                                class_name: 'GrantSubmission::Response',
                                foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    belongs_to :parent,         class_name: 'GrantSubmission::Submission',
                                foreign_key: 'parent_id',
                                inverse_of: :children,
                                optional: true
    has_many :children,         class_name: 'GrantSubmission::Submission',
                                dependent: :destroy,
                                foreign_key: 'parent_id',
                                inverse_of: :parent
    has_many :reviews,          dependent: :destroy,
                                foreign_key: 'grant_submission_submission_id',
                                inverse_of: :submission
    has_many :reviewers,        through: :reviews,
                                source: :reviewer
    has_many :criteria_reviews, through: :reviews


    accepts_nested_attributes_for :responses, allow_destroy: true
    accepts_nested_attributes_for :children, allow_destroy: true

    validates_presence_of :title
    validates_presence_of :form,    :if => Proc.new { |rs| rs.is_root? }
    validates_presence_of :section, :if => Proc.new { |rs| !rs.is_root? }

    scope :eager_loading,         -> {includes({:responses => [:question]}, :children)}

    scope :order_by_created_at,   -> { order(created_at: :desc) }
    scope :by_grant,              -> (grant) { where(grant_id: grant.id) }
    scope :to_be_assigned,        -> (max) { where(["reviews_count < ?", max]) }
    scope :with_reviews,          -> { includes(reviews: [:reviewer, :criteria_reviews]) }

    def form_owner
      user || grant
    end

    def all_responses_including_children
      responses.to_a + children.map(&:all_responses_including_children).flatten
    end

    def responded_to
      section || form
    end

    def contains_referenced_children?
      children.any? {|child_rs| child_rs.follow_ups.present?}
    end

    def children_for_section(section)
      # not using where() here because this method might be called on a new record not in database yet
      children.select {|sub_rs| sub_rs.section == section}.sort
    end

    def form_dates
      []
      #responses.select {|r| r.question.is_cycle_date}.map {|r| r.to_form_date_pair} + children.map(&:form_dates).flatten(1)
    end

    def last_updated_object
      luo = ([self, responses.max_by(&:updated_at)] + children.map(&:last_updated_object))
                .compact.max_by(&:updated_at)
      luo if luo && luo.created_at != luo.updated_at
    end

    # ignore whodunnits which are not integer, these would be system data migrations
    # data migrations should not touch updated_at
    def last_updated_object_version
      if luo = last_updated_object
        luo.versions.reverse.find {|v| /^[0-9]+$/ =~ v.whodunnit.to_s}
      end
    end

    def is_root?
      parent.blank?
    end

    # TODO: available? to...edit? delete?
    def available?
      return true
      # TODO: Figure out policies
      #       HIGH PRIORITY
      # is_root? ? super : parent.available?
    end

    def response_for_question(question_id)
      responses.select {|r| r.grant_submission_question_id == question_id}.first
    end

    def <=> other
      return 0 if !id && !other.id
      return 1 if !id
      return -1 if !other.id
      # (baseline_id || id) <=> (other.baseline_id || other.id)
      id <=> other.id
    end

    ## TODO: Do we need anything from this?
    # include FormStatus -- see notis lib/form_status.rb


    # TODO: Review these methods
    #   The following methods were moved from app/models/form_base
    def date_order
      d = form_dates.map(&:first).compact.min
      [d ? 1 : 0, d || 0]
    end

    def get_applicant_id
      # if self.class.column_names.include?("applicantid")
      #   applicant_id = self.applicant_id
      # elsif self.class.include?(PaperTrail::Model::InstanceMethods) &&
      #     self.class.paper_trail.enabled? &&
      #     self.paper_trail.enabled_for_model?
      #   if applicant_id = self.get_first_applicant
      #   elsif (first_version = self.versions.first) && !first_version.object.blank?
      #     applicant_id = YAML.load(first_version.object)['applicant_id']
      #   end
      # end
      applicant_id
    end

    # def get_first_applicant
    #   raise Form.new('Method moved from FormBase')
    #   # self.versions.loaded? ?
    #   #     self.versions.select {|v| v.event == 'create'}.first.try(:whodunnit) :
    #   #     self.versions.where(event: 'create').first.try(:whodunnit)
    # end

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
