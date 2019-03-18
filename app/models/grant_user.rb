# frozen_string_literal: true

class GrantUser < ApplicationRecord
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

  scope :with_users, -> { includes :users }
end
