# frozen_string_literal: true

module GrantServices
  module DuplicateDependencies
    def self.call(original_grant:, new_grant:)
      begin
        ActiveRecord::Base.transaction(requires_new: true) do
          new_grant.save!

          original_grant.grant_users.each do |grant_user|
            GrantUserServices::Duplicate.call(original_grant_user: grant_user, new_grant: new_grant)
          end

          original_grant.questions.each do |question|
            QuestionServices::Duplicate.call(question: question, new_grant: new_grant)
          end
        end
        OpenStruct.new(success?: true)
      rescue
        #TODO: Log errors
        errors = new_grant.errors.any? ? new_grant.errors.full_messages : 'An error occurred while saving. Please try again.'
        OpenStruct.new(success?: false,
                       messages: errors)
      end
    end
  end
end
