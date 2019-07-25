# frozen_string_literal: true

class AccessPolicy < ApplicationPolicy
  private

  def clean_record_from_collection
    clean_record = record.try(:first) ? record.first : record
  end
end
