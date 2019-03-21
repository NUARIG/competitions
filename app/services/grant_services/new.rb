# frozen_string_literal: true

module GrantServices
  ADMIN_ROLE       = 'admin'
  SUCCESS_MESSAGE  = 'Success.'
  ROLLBACK_MESSAGE = 'An error has occurred. Please try again.'

  module New
    def self.call(grant:, user:)
      begin
        # TODO: is requires_new needed?
        ActiveRecord::Base.transaction(requires_new: true) do
          grant.save!

          GrantUser.create(grant: grant, user: user, grant_role: ADMIN_ROLE)

          DefaultSet.find(grant.default_set).questions.ids.each do |q_id|
            Question.find(q_id).dup.update_attributes!(grant_id: grant.id)
            ConstraintQuestion.where(question_id: q_id).each do |constraint_question|
              constraint_question.dup.update_attributes!(question_id: q_id)
            end
          end

        end
        OpenStruct.new(success?: true, messages: self.parent.SUCCESS_MESSAGE)
      rescue
        #TODO: Log errors?
        OpenStruct.new(success?: false,
                       messages: grant.errors.any? ? grant.errors.full_messages : self.parent.ROLLBACK_ERROR)
      end
    end
  end
end
