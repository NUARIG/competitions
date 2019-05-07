# frozen_string_literal: true

module GrantServices
  module New
    def self.call(grant:, user:)
      begin
        # TODO: is requires_new needed?
        ActiveRecord::Base.transaction(requires_new: true) do
          grant.save!

          GrantPermission.create!(grant: grant, user: user, role: 'admin')

        end
        OpenStruct.new(success?: true)
      rescue
        #TODO: Log errors
        OpenStruct.new(success?: false,
                       messages: grant.errors.any? ? grant.errors.full_messages : 'An error occurred while saving. Please try again.')
      end
    end
  end
end
