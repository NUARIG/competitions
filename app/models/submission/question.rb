module Submission
  class Question < ApplicationRecord
    self.table_name = 'submission_questions'
    #has_paper_trail ignore: [:display_order]
    belongs_to :section,               class_name: 'Submission::Section',
                                       foreign_key: 'submission_section_id',
                                       inverse_of: :questions
    has_many :multiple_choice_options, class_name: 'Submission::MultipleChoiceOption',
                                       dependent: :destroy,
                                       foreign_key: 'submission_question_id',
                                       inverse_of: :question
    has_many :responses,               class_name: 'Submission::Response',
                                       foreign_key: 'submission_question_id',
                                       inverse_of: :question

    accepts_nested_attributes_for :multiple_choice_options, allow_destroy: true

    VIEW_RESPONSE_TYPE_TRANSLATION = {
      pick_one:      "Multiple Choice - Pick One",
      number:        "Number",
      short_text:    "Short Text (255 max)",
      long_text:     "Long Text (unlimited)",
      date_opt_time: "Date w/ Optional Time",
      partial_date:  "Partial Date",
      file_upload:   "File Upload (15 MiB max)"
    }.freeze

    validates_presence_of   :section, :text, :display_order, :response_type
    validates_inclusion_of  :response_type, in: VIEW_RESPONSE_TYPE_TRANSLATION.keys.map(&:to_s)
    validates_uniqueness_of :text, scope: :submission_section_id
    validates_inclusion_of  :is_mandatory, in: [true, false], message: "can't be blank"

    validates_numericality_of :display_order, only_integer: true, greater_than: 0
    validates_length_of :text, maximum: 4000
    validates_length_of :export_code, maximum: 255
    validates_length_of :instruction, maximum: 4000


    def self.human_readable_attribute(attr)
      {}[attr] || attr.to_s.humanize
    end

    def to_export_hash
      {
        text:               text,
        instruction:        instruction,
        display_order:      display_order,
        export_code:        export_code,
        is_mandatory:       is_mandatory,
        response_type:      response_type,
        answers_attributes: answers.map(&:to_export_hash)
      }
    end

    def to_identifiable_hash
      {
          section_display_order: section.display_order,
          display_order: self.display_order,
          text: self.text
      }
    end

    def self.by_identifiable_hash(submission, hash)
      section = submission.sections.where(display_order: hash['section_display_order']).first
      section.questions.where(display_order: hash['display_order'], text: hash['text']).first
    end

    def available?
      new_record? || section.submission.available?
    end

    def submission
      section.submission
    end

    def human_readable_description
      "Question #{section.title} - #{display_order}. #{text}"
    end

    def global_report_display_name
      "#{submission.title}: #{human_readable_description}"
    end

    def operator_types
      case response_type.to_sym
      when :pick_one, :standard_answer
        ['list', 'comparable']
      when :short_text, :long_text
        ['text', 'comparable']
      when :number
        ['comparable']
      when :date_opt_time
        ['comparable', 'duration']
      else
        []
      end
    end

    def has_export_code_in_answers?
      false
      # case response_type.to_sym
      # when :pick_one
      #   answers.any? {|answer| answer.export_code.present?}
      # when :standard_answer
      #   standard_answer_set.standard_answers.any? {|standard_answer| standard_answer.export_code.present?}
      # else
      #   false
      # end
    end
  end
end
