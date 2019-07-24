# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :organization
  has_many   :grant_permissions
  has_many   :editable_grants,        through: :grant_permissions,
                                      source: :grant

  has_many   :grant_reviewers
  has_many   :reviewable_grants,      through: :grant_reviewers,
                                      source: :grant

  has_many   :submissions,            class_name: 'GrantSubmission::Submission',
                                      foreign_key: :created_id,
                                      inverse_of: :applicant
  has_many   :applied_grants,         through: :submissions,
                                      source: :grant

  has_many   :reviews,                inverse_of: :reviewer,
                                      foreign_key: :reviewer_id
  has_many   :reviewable_submissions, through: :reviews,
                                      source: :submission

  after_initialize :set_default_organization_role, if: :new_record?

  ORG_ROLES = { admin: 'admin',
                none: 'none' }.freeze

  enum organization_role: ORG_ROLES, _prefix: true

  validates :organization,      presence: true
  validates :organization_role, presence: true
  validates :email,             presence: true,
                                uniqueness: true
  validates :first_name,        presence: true
  validates :last_name,         presence: true

  scope :with_organization, -> { includes :organization }

  def name
    "#{first_name} #{last_name}".strip
  end

  private

  def set_default_organization_role
    self.organization_role ||= :none
  end
end
