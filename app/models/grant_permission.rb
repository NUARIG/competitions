# frozen_string_literal: true

class GrantPermission < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::GrantPermissionVersion' },
                  meta:     { grant_id: :grant_id, user_id: :user_id }

  belongs_to :grant
  belongs_to :user

  ROLES = { admin: 'admin',
            editor: 'editor',
            viewer: 'viewer' }
  ROLES.default = 'none'
  ROLES.freeze

  enum role: ROLES, _prefix: true

  before_destroy :prevent_last_admin_destroy, if: -> { role_admin? && is_last_grant_admin? }

  validates :grant, presence: true
  validates :user, presence: true
  validates :role, presence: true

  validates_uniqueness_of :user_id, scope: :grant_id, message: 'can only be assigned once.'

  validate :prevent_last_admin_edit, on: :update, if: -> { role_changed? && role_changed_from_admin? && is_last_grant_admin? }

  def self.role_by_user_and_grant(user:, grant:)
    return GrantPermission::ROLES[:admin] if user.system_admin?
    GrantPermission.find_by(grant: grant, user: user)&.role
  end

  def self.submission_notification_emails(grant: grant)
    User.find(GrantPermission.where(grant: grant, submission_notification: true).map { |gp| gp.user_id }).map { |u| u.email }
  end

  private

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
