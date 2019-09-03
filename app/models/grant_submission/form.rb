class GrantSubmission::Form < ApplicationRecord

    self.table_name = 'grant_submission_forms'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::FormVersion' },
                    meta:     { grant_id: :grant_id }

    # TODO: Add _versions table
    # has_paper_trail

    belongs_to :grant,                 class_name: 'Grant',
                                       inverse_of: :form
    has_many :sections,                class_name: 'GrantSubmission::Section',
                                       foreign_key: 'grant_submission_form_id',
                                       dependent: :destroy,
                                       inverse_of: :form
    has_many :submissions,             class_name: 'GrantSubmission::Submission',
                                       foreign_key: 'grant_submission_form_id',
                                       inverse_of: :form
    has_many :questions,               through: :sections
    has_many :multiple_choice_options, through: :questions
    # has_many :grant_forms,             foreign_key: 'grant_submission_form_id',
    #                                    inverse_of: :form
    # has_many :grants,                  through: :grant_forms

    # TODO: CONFIRM WHETHER THIS WORKS
    # Prevents editing of forms with submission
    # first_submission_id is dynamic, not in database
    # has_one :first_submission_id, -> { select(:id, :grant_submission_form_id).limit(1) },
    #                               class_name: 'GrantSubmission::Submission',
    #                               foreign_key: 'grant_submission_submission_id',
    #                               inverse_of: :form

    # Added for speed
    belongs_to :form_created_by, class_name: 'User',
                                 foreign_key: :created_id
    belongs_to :form_updated_by, class_name: 'User',
                                 foreign_key: :updated_id

    accepts_nested_attributes_for :sections, allow_destroy: true
    validates_presence_of :title
    validates_uniqueness_of :title
    validates_uniqueness_of :grant
    validates_length_of :title, maximum: 255
    validates_length_of :description, maximum: 3000

    scope :search_by_title, -> (keyword) { where("UPPER(#{self.table_name}.title) LIKE ?", "%#{keyword.upcase}%")}
    scope :with_questions,  -> () { includes(form: :questions) }
    scope :with_sections_questions_options, -> () { includes(sections: { questions: :multiple_choice_options })}


    scope :order_by, ->(column, direction) {
      return unless SORTABLE_FIELDS.include?(column)
      case column
      when 'title'
        sort_sql = 'UPPER(TRIM(title))'
        order("#{sort_sql} #{direction} NULLS LAST, id #{direction}")
      # when 'updated_by'
      #   left_joins(:form_updated_by).order("#{Person.table_name}.first_name #{direction} NULLS LAST,
      #     #{Person.table_name}.last_name #{direction} NULLS LAST, id #{direction}")
      # when 'created_by'
      #   left_joins(:form_created_by).order("#{Person.table_name}.first_name #{direction} NULLS LAST,
      #     #{Person.table_name}.last_name #{direction} NULLS LAST, id #{direction}")
      else
        sort_sql = column
        order("#{sort_sql} #{direction} NULLS LAST, id #{direction}")
      end
    }

    SORTABLE_FIELDS = %w[title created_at updated_at description].freeze # created_by updated_by
    ALWAYS_EDITABLE_ATTRIBUTES = %w[description] # show_ans_code_in_form_entry show_ans_code_in_sep_exp_col

    def self.human_readable_attribute(attr)
      {show_ans_code_in_form_entry: 'Show answer export code when entering forms',
       show_ans_code_in_sep_exp_col: 'Show answer export code as separate column in exports'
      }[attr] || attr.to_s.humanize
    end

    def sorted_questions
      questions.sort_by {|q| [q.section.display_order, q.display_order]}
    end

    def sorted_questions_and_repeatable_sections
      sections.includes(:questions).order(:display_order).collect {|sec| section.repeatable ? sec : section.questions.sort_by {|q| q.display_order}}.flatten
    end

    def to_export_hash
      {
          title: title,
          description: description,
          sections_attributes: sections.includes(questions: :multiple_choice_options).map(&:to_export_hash) #,
      }
    end

    # TODO: What does available mean here?
    #       available...to edit? ...to submit?
    #       Do we need an appliable? method in grant
    def available?
      new_record? || (submissions.none? && !grant.published?)
    end

    def destroyable?
      false
      # available? && grant_forms.empty? # && mb_messages.empty? && instructions.empty?
    end

    # this will re-number
    # sections/questions/multiple_choice_options from an offset while still respecting
    # the assigned order. Next it will re-number again from 1 to clean
    # things up.  this is all to allow database constraints on
    # uniqueness of display order.  Using a DEFERRABLE database
    # constraint is avoided at this time to avoid additional coupling
    # with oracle. The offset must be large enough to
    # account for existing display orders in the db and new records
    # being created. e.g. add questions and reorder at the same time.
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
        ok = save

        reorder.(sections, false)
        sections.each { |section| reorder.(section.questions, false) }
        sections.flat_map(&:questions).each do |question|
          reorder.(question.multiple_choice_options, false) if question.multiple_choice_options.present?
        end
        ok = save && ok
        return ok
      else
        return false
      end
    end

    def convert_virtual_attrs!
      success = true
      return {success: success, error_msg: nil}
    end

    def human_readable_description
      "Form: #{title}"
    end

end
