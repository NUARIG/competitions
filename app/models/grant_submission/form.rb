class GrantSubmission::Form < ApplicationRecord

  self.table_name = 'grant_submission_forms'
  has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::FormVersion' },
                  meta:     { grant_id: :grant_id }

  belongs_to :grant,                   class_name: 'Grant',
                                       inverse_of: :form
  has_many   :sections,                class_name: 'GrantSubmission::Section',
                                       foreign_key: 'grant_submission_form_id',
                                       dependent: :destroy,
                                       inverse_of: :form
  has_many   :submissions,             class_name: 'GrantSubmission::Submission',
                                       foreign_key: 'grant_submission_form_id',
                                       inverse_of: :form
  has_many   :questions,               through: :sections
  has_many   :multiple_choice_options, through: :questions
  belongs_to :form_created_by,         class_name: 'User',
                                       foreign_key: :created_id
  belongs_to :form_updated_by,         class_name: 'User',
                                       foreign_key: :updated_id

  accepts_nested_attributes_for :sections, allow_destroy: true

  validates_uniqueness_of :grant
  validates_length_of     :submission_instructions, maximum: 3000

  scope :with_questions,  -> () { includes(form: :questions) }
  scope :with_sections_questions_options, -> () { includes(sections: { questions: :multiple_choice_options })}

  # Is the grant available to be edited?
  def available?
    new_record? || (submissions.none? && !grant.published?)
  end

  def destroyable?
    false
    # available? && grant_forms.empty? && instructions.empty?
  end

  # This method first re-numbers sections/questions/answers from an offset
  # while still respecting the created_at order.
  #   The offset must be large enough to account for existing display orders
  #   in the db and new records to be created.
  # It then re-orders from 1 to clean things up. This allows database
  # constraints on uniqueness of display order.
  def update_safe_display_order(params)

    reorder = ->(relation, offset) do
      return if relation.size == 0
      start = offset ? [relation.size, *relation.pluck(:display_order), *relation.map(&:display_order)].compact.max.to_i + 1 : 1
      relation.each { |item| item.created_at = DateTime.now if item.created_at.nil? }
      relation.sort_by(&:created_at).each_with_index {|el, i| el.display_order = start + i}
    end

    assign_attributes(params)

    if valid?
      reorder.(sections, true)
      sections.each {|s| reorder.(s.questions, true)}
      sections.flat_map(&:questions).each {|q| reorder.(q.multiple_choice_options, true)}
      offset_saved = save

      reorder.(sections, false)
      sections.each {|s| reorder.(s.questions, false)}
      sections.flat_map(&:questions).each {|q| reorder.(q.multiple_choice_options, false)}
      ordered_save = save

      return (offset_saved && ordered_save)
    else
      return false
    end
  end
end
