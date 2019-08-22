class GrantCreatorRequest < ApplicationRecord
  after_save :udpate_user_grant_creator_attribute, if: :saved_change_to_status?

  STATUSES  = { pending:  'Pending',
                approved: 'Approved',
                rejected:  'Rejected'}.freeze

  enum status: STATUSES, _prefix: true

  belongs_to :requester, class_name:  'User',
                         foreign_key: 'requester_id'
  belongs_to :reviewer,  class_name: 'User',
                         foreign_key: 'reviewer_id',
                         optional: true

  before_validation :set_default_status, if: :new_record?

  validates_presence_of :request_comment, on: %i[create update]

  validate :requester_has_no_pending_requests, on: :create
  validate :requester_is_not_a_system_admin,   on: :create
  validate :requester_is_not_a_grant_creator,  on: :create
  validate :reviewer_is_a_system_admin,          on: :update, if: :reviewer_id_changed?

  scope :pending, -> { where(status: STATUSES[:pending]) }

  private

  def set_default_status
    self.status ||= GrantCreatorRequest::STATUSES[:pending]
  end

  def requester_has_no_pending_requests
    errors.add(:base, :pending_request) if requester.grant_creator_requests.pending.any?
  end

  def requester_is_not_a_grant_creator
    errors.add(:base, :has_grant_creator_access) if requester.grant_creator?
  end

  def requester_is_not_a_system_admin
    errors.add(:base, :is_system_admin) if requester.system_admin?
  end

  def reviewer_is_a_system_admin
    errors.add(:base, :reviewer_is_not_system_admin) if !reviewer.system_admin?
  end

  def udpate_user_grant_creator_attribute
    case status
    when 'approved'
      requester.update_attribute(:grant_creator, true)
      GrantCreatorRequestReviewMailer.with(request: self).approved.deliver_now
    when 'rejected'
      requester.update_attribute(:grant_creator, false)
      GrantCreatorRequestReviewMailer.with(request: self).rejected.deliver_now
    else
      requester.update_attribute(:grant_creator, false)
    end
  end
end
