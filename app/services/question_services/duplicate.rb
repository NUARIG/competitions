# frozen_string_literal: true

module QuestionServices
  module Duplicate
    def self.call(question:, new_grant:)
      begin
        ActiveRecord::Base.transaction(requires_new: true) do
          new_question = question.dup
          new_question.update_attributes!(grant: new_grant)

          question.constraint_questions.each do |constraint_question|
            ActiveRecord::Base.transaction(requires_new: true) do
              new_constraint_question = constraint_question.dup
              new_constraint_question.update_attributes!(question: new_question)
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        # how to handle this?
      end
    end
  end
end
