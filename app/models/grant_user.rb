# frozen_string_literal: true

class GrantUser < ApplicationRecord
  # include WithGrantRoles

  belongs_to :grant
  belongs_to :user

  GRANT_ROLES = { admin: 'admin',
                  editor: 'editor',
                  viewer: 'viewer' }.freeze

  enum grant_role: GRANT_ROLES, _prefix: true

  validates :grant, presence: true
  validates :user, presence: true
  validates :grant_role, presence: true

  validates_uniqueness_of :user_id, scope: :grant_id, message: 'can only be assigned once.'

  validate :validate_user_and_grant_organizations, if: -> { grant.present? && user.present? }

  scope :with_users, -> { includes :users }

  private

  def validate_user_and_grant_organizations
    errors.add(:base, 'User must be associated with the same organization as the grant.') unless grant.organization.id == user.organization.id
  end
end
