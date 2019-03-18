# frozen_string_literal: true

class AccessPolicy < ApplicationPolicy
  private
  # Organization access
  def organization_admin_access?
    user.organization_role == 'admin'
  end

  def clean_record_from_collection
    clean_record = record.try(:first) ? record.first : record
  end
end
