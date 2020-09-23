class Panel < ApplicationRecord
  belongs_to :grant

  validates_datetime :start_datetime, before: :end_datetime,
                                      if: -> { start_datetime.present? || end_datetime.present? }

  validates_uniqueness_of :grant
end
