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

          original_grant.criteria.each do |criterion|
            CriterionServices::Duplicate.call(original_criterion: criterion, new_grant: new_grant)
          end

          GrantSubmissionFormServices::Duplicate.call(original_grant: original_grant, new_grant: new_grant)

        end
        OpenStruct.new(success?: true)
      rescue ActiveRecord::RecordInvalid => invalid
        OpenStruct.new(success?: false,
                       messages: invalid.record.errors.full_messages)
      rescue ServiceError::InputInvalid => invalid
        OpenStruct.new(success?: false,
                       messages: invalid.record.errors.full_messages)
      end
    end
  end
end
