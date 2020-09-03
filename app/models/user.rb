# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :grant_permission_role

  devise :trackable, :timeoutable

  USER_TYPES = ["SamlUser", "RegisteredUser"]

  has_paper_trail versions: { class_name: 'PaperTrail::UserVersion' },
                  meta:     { user_id: :id } # added for convenience

  has_many   :grant_permissions
  has_many   :editable_grants,        through: :grant_permissions,
                                      source: :grant

  has_many   :grant_reviewers,        foreign_key: :reviewer_id,
                                      inverse_of: :reviewer
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

  has_many   :grant_creator_requests, foreign_key: :requester_id,
                                      inverse_of: :requester

  validates :uid,               presence: true,
                                uniqueness: true
  validates :email,             presence: true,
                                uniqueness: true
  validates :first_name,        presence: true
  validates :last_name,         presence: true

  validates_uniqueness_of :era_commons, unless: -> { era_commons.blank? }

  scope :order_by_last_name,                          -> { order(last_name: :asc) }
  scope :sort_by_type_nulls_last_asc,                 -> { order(Arel.sql('type ASC, CASE WHEN current_sign_in_at IS NULL THEN 2 ELSE 1 END')) }
  scope :sort_by_type_nulls_last_desc,                -> { order(Arel.sql('type DESC, CASE WHEN current_sign_in_at IS NULL THEN 2 ELSE 1 END')) }
  scope :sort_by_current_sign_in_at_nulls_last_asc,   -> { order('current_sign_in_at ASC NULLS LAST') }
  scope :sort_by_current_sign_in_at_nulls_last_desc,  -> { order('current_sign_in_at DESC NULLS LAST') }


  def saml_user?
    self.type === 'SamlUser'
  end

  def registered_user?
    self.type === 'RegisteredUser'
  end

  def get_role_by_grant(grant:)
    self.grant_permission_role ||= {}
    self.grant_permission_role[grant] ||= GrantPermission.role_by_user_and_grant(user: self, grant: grant)
  end

  # https://github.com/varvet/pundit/issues/478#issuecomment-371737216
  # Needed so that subclasses inherit the policy from User class.
  def self.policy_class
    UserPolicy
  end
end
