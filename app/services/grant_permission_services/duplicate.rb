# frozen_string_literal: true

module GrantPermissionServices
  module Duplicate
    def self.call(original_grant_permission:, new_grant:)
      new_permission = original_grant_permission.dup
      new_permission.update!(grant: new_grant)
    rescue ActiveRecord::RecordInvalid => invalid
      raise ServiceError::InputInvalid.new(error: invalid)
    end
  end
end
