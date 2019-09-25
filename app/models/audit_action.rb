# frozen_string_literal: true

class AuditAction < ApplicationRecord
  belongs_to :user
end
