# frozen_string_literal: true

module GrantSubmission
  class Submission::Applicant < ApplicationRecord
    # has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmissionSubmissionPermissionVersion' },
    #                 meta:     { grant_submission_submission_id: :grant_submission_submission_id,
    #                             user_id: :user_id }

    belongs_to :submission,   class_name: 'GrantSubmission::Submission',
                              foreign_key: 'grant_submission_submission_id',
                              inverse_of: :applicants
    belongs_to :user

    ROLES = { primary: 'primary' }

    ROLES.default = 'none'
    ROLES.freeze

    enum role: ROLES, _prefix: true

    # before_destroy :prevent_last_admin_destroy, if: -> { role_admin? && is_last_grant_admin? }

    validates :submission,  presence: true
    validates :user,        presence: true
    validates :role,        presence: true

    validates_uniqueness_of :user_id, scope: :submission_id, message: 'can only be assigned once.'

    # validate :prevent_last_admin_edit, on: :update, if: -> { role_changed? && role_changed_from_admin? && is_last_grant_admin? }

    # def self.role_by_user_and_grant(user:, grant:)
    #   return GrantPermission::ROLES[:admin] if user.system_admin?
    #   GrantPermission.find_by(grant: grant, user: user)&.role
    # end

    # def self.submission_notification_emails(grant: grant)
    #   User.find(GrantPermission.where(grant: grant, submission_notification: true).map { |gp| gp.user_id }).map { |u| u.email }
    # end

    private

    def prevent_last_applicant_edit
      errors.add(:base, 'There must be at least one applicant on the grant')
    end

    def prevent_last_applicant_destroy
      errors.add(:base, 'This user\'s role cannot be deleted.')
      throw :abort
    end

    def is_last_submission_applicant?
      submission.submission_permissions.role_applicant.one?
    end

    def role_changed_from_applicant?
      role_was == ROLES[:applicant]
    end
  end
end