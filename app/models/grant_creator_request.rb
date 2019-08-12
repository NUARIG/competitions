class GrantCreatorRequest < ApplicationRecord

  STATUSES  = { pending:  'Pending',
                approved: 'Approved',
                rejected:  'Rejected'}.freeze

  enum status: STATUSES, _prefix: true

  attribute :status, default: STATUSES[:pending]

  belongs_to :requester, class_name:  'User',
                         foreign_key: 'requester_id'
  belongs_to :reviewer,  class_name: 'User',
                         foreign_key: 'reviewer_id',
                         optional: true

  validates_presence_of :request_comment, on: %i[create update]

  validate :requester_has_no_pending_requests, on: :create
  validate :requester_is_not_a_system_admin,   on: :create
  validate :requester_is_not_a_grant_creator,  on: :create

  scope :pending, -> { where(status: STATUSES[:pending]) }

  private

  def requester_has_no_pending_requests
    errors.add(:base, :pending_request) if requester.grant_creator_requests.pending.any?
  end

  def requester_is_not_a_grant_creator
    errors.add(:base, :has_grant_creator_access) if requester.grant_creator?
  end

  def requester_is_not_a_system_admin
    errors.add(:base, :is_system_admin) if requester.system_admin?
  end
end
