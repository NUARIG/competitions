module GrantSubmission
  class MultipleChoiceOption < ApplicationRecord
    self.table_name = 'grant_submission_multiple_choice_options'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::MultipleChoiceOptionVersion' },
                    meta:     { grant_submission_question_id: :grant_submission_question_id }

    belongs_to :question,  class_name: 'GrantSubmission::Question',
                           foreign_key: 'grant_submission_question_id',
                           inverse_of: :multiple_choice_options
    has_many   :responses, class_name: 'GrantSubmission::Response',
                           foreign_key: 'grant_submission_multiple_choice_option_id',
                           inverse_of: :multiple_choice_option

    validates_presence_of   :question, :text
    validates_uniqueness_of :text, scope: :grant_submission_question_id
    validates_length_of     :text, maximum: 255

    def available?
      new_record? || question.section.form.available?
    end
  end
end
