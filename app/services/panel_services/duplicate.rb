# frozen_string_literal: true

module PanelServices
  module Duplicate
    def self.call(original_grant:, new_grant:)
      new_panel = original_grant.panel.dup
      new_panel.update(grant: new_grant, start_datetime: nil, end_datetime: nil)
    rescue ActiveRecord::RecordInvalid => invalid
      raise ServiceError::InputInvalid.new(error: invalid)
    end
  end
end
