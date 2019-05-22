module GrantSubmission
  class MultipleChoiceOption < ApplicationRecord
    self.table_name = 'grant_submission_multiple_choice_options'

    # has_paper_trail ignore: [:display_order]

    belongs_to :question,  class_name: 'GrantSubmission::Question',
                           foreign_key: 'grant_submission_question_id',
                           inverse_of: :multiple_choice_options
    has_many   :responses, class_name: 'GrantSubmission::Response',
                           foreign_key: 'grant_submission_multiple_choice_option_id',
                           inverse_of: :multiple_choice_option

    validates_presence_of :question, :text, :display_order
    validates_uniqueness_of :text, scope: :grant_submission_question_id
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
