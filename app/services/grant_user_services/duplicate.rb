# frozen_string_literal: true

module GrantUserServices
  module Duplicate
    def self.call(original_grant_user:, new_grant:)
      new_permission = original_grant_user.dup
      new_permission.update_attributes!(grant: new_grant)
    end
  end
end
