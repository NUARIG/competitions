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
    # available? && grant_forms.empty? # && mb_messages.empty? && instructions.empty?
  end

  # First, re-number sections/questions/multiple_choice_options from an offset
  # while respecting the assigned order.
  # Then, to clean things up, re-number again from 1.
  # Allows for display order uniqueness database constraints. The offset must be
  # large enough to account for existing display orders in the db and new records
  # being created. e.g. Add questions and reorder at the same time.
  def update_attributes_safe_display_order(params)
    reorder = ->(relation, offset) do
                  return if relation.size == 0
                  start = offset ? [relation.size, *relation.pluck(:display_order), *relation.map(&:display_order)].compact.max.to_i + 1 : 1
                  relation.each_with_index {|el, i| el.display_order = start + i }
                end

    assign_attributes(params)

    if valid?
      reorder.(sections, true)
      sections.each { |section| reorder.(section.questions, true) }
      sections.flat_map(&:questions).each do |question|
        reorder.(question.multiple_choice_options, true) if question.multiple_choice_options.present?
      end

      offset_saved = save

      reorder.(sections, false)
      sections.each { |section| reorder.(section.questions, false) }
      sections.flat_map(&:questions).each do |question|
        reorder.(question.multiple_choice_options, false) if question.multiple_choice_options.present?
      end

      saved = save

      return (offset_saved && saved)
    else
      return false
    end
  end
end
