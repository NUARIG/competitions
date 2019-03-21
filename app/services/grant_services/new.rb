# frozen_string_literal: true

module GrantServices
  module New
    def self.call(grant:, user:)
      begin
        # TODO: is requires_new needed?
        ActiveRecord::Base.transaction(requires_new: true) do
          grant.save!

          GrantUser.create(grant: grant, user: user, grant_role: 'admin')

          DefaultSet.find(grant.default_set).questions.ids.each do |q_id|
            ActiveRecord::Base.transaction(requires_new: true) do
              new_question = Question.find(q_id).dup
              new_question.update_attributes!(grant_id: grant.id)
              ConstraintQuestion.where(question_id: q_id).each do |constraint_question|
                ActiveRecord::Base.transaction(requires_new: true) do
                  new_constraint_question = constraint_question.dup
                  new_constraint_question.update_attributes!(question_id: new_question.id)
                end
              end
            end
          end
        end
        OpenStruct.new(success?: true)
      rescue
        #TODO: Log errors?
        OpenStruct.new(success?: false,
                       messages: grant.errors.any? ? grant.errors.full_messages : 'An error occurred while saving. Please try again.')
      end
    end
  end
end
