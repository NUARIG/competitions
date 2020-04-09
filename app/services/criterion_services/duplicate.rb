# frozen_string_literal: true

module CriterionServices
  module Duplicate
    def self.call(original_criterion:, new_grant:)
      new_criterion = original_criterion.dup
      new_criterion.update_attributes!(grant: new_grant)
    rescue ActiveRecord::RecordInvalid => invalid
      raise ServiceError.new(invalid: invalid)
    end
  end
end
