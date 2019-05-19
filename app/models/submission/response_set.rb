module Submission
  class ResponseSet < ApplicationRecord
    # include EncodingErrorRecoverable

    self.table_name = 'submission_response_sets'

    # TODO: Add versions table
    #has_paper_trail

    belongs_to :form,    class_name: 'Submission::Form',
                         foreign_key: 'submission_form_id',
                         inverse_of: :response_sets
    belongs_to :section, class_name: 'Submission::Section',
                         foreign_key: 'submission_section_id',
                         optional: true
    belongs_to :creator, class_name: 'User',
                         foreign_key: 'created_id'
    has_many :responses, dependent: :destroy,
                         class_name: 'Submission::Response',
                         foreign_key: 'submission_response_set_id',
                         inverse_of: :response_set
    belongs_to :parent,  class_name: 'Submission::ResponseSet',
                         foreign_key: 'parent_id',
                         inverse_of: :children,
                         optional: true
    has_many :children,  class_name: 'Submission::ResponseSet',
                         dependent: :destroy,
                         foreign_key: 'parent_id',
                         inverse_of: :parent

    has_one :grant_response_set, foreign_key: :submission_response_set_id,
                                 inverse_of: :response_set,
                                 dependent: :destroy
    has_one :grant, through: :grant_response_set

    # has_one :user_submission, foreign_key: :form_submission_id,
    #                           inverse_of: :submission,
    #                           dependent: :destroy
    # has_one :user, through: :user_submission

    accepts_nested_attributes_for :responses, allow_destroy: true

    accepts_nested_attributes_for :children, allow_destroy: true

    validates_presence_of :form, :if => Proc.new {|rs| rs.is_root?}
    validates_presence_of :section, :if => Proc.new {|rs| !rs.is_root?}

    # scope :eager_loading, -> {includes({:responses => [:question, :standard_answer]}, :children)}
    scope :eager_loading, -> {includes({:responses => [:question]}, :children)}


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

    def grant_form
      form.grant_forms.where(grant_id: form_owner.form_grant.id).first
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

    def is_follow_up?
      # baseline_id.present?
      false
    end

    def is_baseline?
      # section.allow_follow_up && !is_follow_up?
      false
    end

    def available?
      return true
      # TODO: Figure out policies
      #       HIGH PRIORITY
      # is_root? ? super : parent.available?
    end

    def show_remove_link?
      # if section.allow_follow_up
      #   (is_baseline? && follow_ups.blank?) || (!is_baseline?)
      # else
        # true
      # end
      true
    end

    def response_for_question(question_id)
      responses.select {|r| r.submission_question_id == question_id}.first
    end

    def <=> other
      return 0 if !id && !other.id
      return 1 if !id
      return -1 if !other.id
      (baseline_id || id) <=> (other.baseline_id || other.id)
    end

    ## TODO: Do we need anything from this?
    # include FormStatus -- see notis lib/form_status.rb


    # TODO: Review these methods
    #   The following methods were moved from app/models/form_base
    def date_order
      d = form_dates.map(&:first).compact.min
      [d ? 1 : 0, d || 0]
    end

    def get_creator_id
      # if self.class.column_names.include?("created_id")
      #   created_id = self.created_id
      # elsif self.class.include?(PaperTrail::Model::InstanceMethods) &&
      #     self.class.paper_trail.enabled? &&
      #     self.paper_trail.enabled_for_model?
      #   if created_id = self.get_first_creator
      #   elsif (first_version = self.versions.first) && !first_version.object.blank?
      #     created_id = YAML.load(first_version.object)['created_id']
      #   end
      # end
      created_id
    end

    def get_first_creator
      raise Form.new('Method moved from FormBase')
      # self.versions.loaded? ?
      #     self.versions.select {|v| v.event == 'create'}.first.try(:whodunnit) :
      #     self.versions.where(event: 'create').first.try(:whodunnit)
    end
  end
end
