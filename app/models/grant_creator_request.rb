class GrantCreatorRequest < ApplicationRecord

  STATUSES  = { pending:  'pending',
                approved: 'approved',
                rejectd:  'rejected'}.freeze

  enum status: STATUSES, _prefix: true

  attribute :status, default: STATUSES[:pending]

  belongs_to :requester, class_name:  'User',
                         foreign_key: 'requester_id'

  validates_presence_of :reasoning, on: :update

  validate :requester_has_no_pending_requests, on: :create
  validate :requester_is_not_a_grant_creator,  on: :create

  scope :by_status, -> (status) { where(status: status) }

  private

  def requester_has_no_pending_requests
    if requester.grant_creator_requests.by_status(STATUSES[:pending]).any?
      errors.add(:base, :pending_request)
    end
  end

  def requester_is_not_a_grant_creator
    errors.add(:base, :has_grant_creator_access) if requester.grant_creator?
  end

end
