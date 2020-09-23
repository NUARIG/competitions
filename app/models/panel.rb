class Panel < ApplicationRecord
  belongs_to :grant

  validates_datetime :start_datetime, before: :end_datetime,
                                      if: -> { start_datetime? || end_datetime? }

  validates_uniqueness_of :grant

  validate :start_is_after_submission_deadline, if: :start_datetime?

  def start_is_after_submission_deadline
    errors.add(:start_datetime, message: 'must be after the submission close date.') if start_datetime > grant.submission_close_date
  end
end
