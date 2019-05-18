module Submission
  class MultipleChoiceOption < ApplicationRecord
    self.table_name = 'submission_multiple_choice_options'
    # has_paper_trail ignore: [:display_order]
    belongs_to :question,  class_name: 'Submission::Question',
                           foreign_key: 'submission_question_id',
                           inverse_of: :answers
    has_many   :responses, class_name: 'Submission::Response',
                           foreign_key: 'submission_answer_id',
                           inverse_of: :answer

    validates_presence_of :question, :text, :display_order
    validates_uniqueness_of :text, scope: :submission_question_id
    validates_numericality_of :display_order, only_integer: true,
                                              greater_than: 0
    validates_length_of :text, maximum: 255

    def self.human_readable_attribute(attr)
      {}[attr] || attr.to_s.humanize
    end

    def to_formatted_s(format = nil)
      # TODO: was export code dependent
      text
    end

    def to_export_hash
      raise FormBuilderException.new('Answer to_export_hash method, no longer needed without export. line 28')
    end

    def available?
      new_record? || question.section.form.available?
    end
  end
end
