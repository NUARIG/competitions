# frozen_string_literal: true

module GrantServices
  module DuplicateDependencies
    def self.call(original_grant:, new_grant:)
      begin
        ActiveRecord::Base.transaction(requires_new: true) do
          new_grant.save!

          original_grant.grant_permissions.each do |grant_permission|
            GrantPermissionServices::Duplicate.call(original_grant_permission: grant_permission, new_grant: new_grant)
          end

          GrantSubmissionFormServices::Duplicate.call(original_grant: original_grant, new_grant: new_grant)

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
