# frozen_string_literal: true

module GrantServices
  module New
    def self.call(grant:, user:)
      # TODO: is requires_new needed?
      ActiveRecord::Base.transaction(requires_new: true) do
        grant.save!
        # Add user as admin
        GrantPermission.create!(grant: grant, user: user, role: 'admin')
        # Create a starter form
        GrantSubmissionFormServices::New.call(grant: grant, user: user)
        # Create starter criteria
        CriterionServices::New.call(grant: grant)
        # Create starter panel
        Panel.create!(grant: grant)
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
