module GrantSubmission
  class Question < ApplicationRecord
    self.table_name = 'grant_submission_questions'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::QuestionVersion' },
                    meta:     { grant_submission_section_id: :grant_submission_section_id }

    belongs_to :section,               class_name: 'GrantSubmission::Section',
                                       foreign_key: 'grant_submission_section_id',
                                       inverse_of: :questions
    has_many :multiple_choice_options, class_name: 'GrantSubmission::MultipleChoiceOption',
                                       dependent: :destroy,
                                       foreign_key: 'grant_submission_question_id',
                                       inverse_of: :question
    has_many :responses,               class_name: 'GrantSubmission::Response',
                                       foreign_key: 'grant_submission_question_id',
                                       inverse_of: :question
    has_one :form,                     through: :section,
                                       class_name: 'GrantSubmission::Form',
                                       foreign_key: 'grant_submission_form_id'

    accepts_nested_attributes_for :multiple_choice_options, allow_destroy: true

    VIEW_RESPONSE_TYPE_TRANSLATION = { pick_one:      'Multiple Choice - Pick One',
                                       number:        'Number',
                                       short_text:    'Short Text (255 chars max)',
                                       long_text:     'Long Text (4000 chars max)',
                                       date_opt_time: 'Date',
                                       file_upload:   'File Upload (15 MB max)'
                                     }.freeze

    validates_presence_of     :response_type, :section, :text
    validates_inclusion_of    :response_type, in: VIEW_RESPONSE_TYPE_TRANSLATION.keys.map(&:to_s)
    validates_uniqueness_of   :text, scope: :section
    validates_uniqueness_of   :display_order, scope: :section
    validates_inclusion_of    :is_mandatory, in: [true, false]
    validates_length_of       :text, maximum: 4000
    validates_length_of       :instruction, maximum: 4000
    validates_numericality_of :display_order, only_integer: true,
                                              greater_than: 0,
                                              if: -> { display_order.present? }

    validate :validate_has_at_least_one_option, if: -> { response_type == 'pick_one' }

    def available?
      new_record? || section.form.available?
    end

    private

    def validate_has_at_least_one_option
      errors.add(:response_type, :requires_option) unless multiple_choice_options.present?
    end
  end
end
