# frozen_string_literal: true

class GrantPermission < ApplicationRecord
  belongs_to :grant
  belongs_to :user

  ROLES = { admin: 'admin',
                  editor: 'editor',
                  viewer: 'viewer' }.freeze

  enum role: ROLES, _prefix: true

  before_destroy :prevent_last_admin_destroy, if: -> { role_admin? && is_last_grant_admin? }

  validates :grant, presence: true
  validates :user, presence: true
  validates :role, presence: true

  validates_uniqueness_of :user_id, scope: :grant_id, message: 'can only be assigned once.'

  validate :prevent_last_admin_edit, on: :update, if: -> { role_changed? && role_changed_from_admin? && is_last_grant_admin? }

  scope :with_users, -> { (includes :users) }

  def prevent_last_admin_edit
    errors.add(:base, 'There must be at least one admin on the grant')
  end

  def prevent_last_admin_destroy
    errors.add(:base, 'This user\'s role cannot be deleted.')
    throw :abort
  end

  def is_last_grant_admin?
    grant.grant_permissions.role_admin.one?
  end

  def role_changed_from_admin?
    role_was == ROLES[:admin]
  end
end