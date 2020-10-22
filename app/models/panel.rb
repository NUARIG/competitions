class Panel < ApplicationRecord
  include Discard::Model

  has_paper_trail versions: { class_name: 'PaperTrail::PanelVersion' },
                  meta:     { grant_id: :grant_id }

  belongs_to :grant

  validates_presence_of :start_datetime,  if: -> { end_datetime? },
                                          message: 'is required if end is provided.'
  validates_presence_of :end_datetime,    if: -> { start_datetime? },
                                          message: 'is required if start is provided.'

  validates_datetime :start_datetime, before: :end_datetime,
                                      if: -> { start_datetime? || end_datetime? },
                                      before_message: 'must be before End Date/Time'

  validates_uniqueness_of :grant
  validates :meeting_link,  if: -> { meeting_link? },
                            format: { with:     /\A(https:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$)\z/ix,
                                      message: 'is not a valid secure URL.' }

  validate :start_is_after_submission_deadline, if: :start_datetime?

  def is_open?
    return false if !start_datetime? || !end_datetime?
    DateTime.now.between?(start_datetime, end_datetime)
  end

  private

  def start_is_after_submission_deadline
    errors.add(:start_datetime, :before_submission_deadline) if start_datetime < grant.submission_close_date.end_of_day
  end
end
