# frozen_string_literal: true

module GrantSubmission
  class Applicant < ApplicationRecord
    self.table_name = 'grant_submission_applicants'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmissionApplicantVersion' },
                    meta:     { grant_submission_submission_id: :grant_submission_submission_id,
                                user_id: :user_id }

    belongs_to :submission,   class_name: 'GrantSubmission::Submission',
                              foreign_key: 'grant_submission_submission_id',
                              inverse_of: :applicants
    belongs_to :user

    ROLES = { primary: 'primary' }

    ROLES.default = 'none'
    ROLES.freeze

    enum role: ROLES, _prefix: true

    before_destroy :prevent_last_primary_applicant_destroy, if: -> { role_primary? && is_last_submission_primary_applicant? }

    validates :submission,  presence: true
    validates :user,        presence: true
    validates :role,        presence: true

    validates_uniqueness_of :user_id, scope: :grant_submission_submission_id, message: 'can only be assigned once.'

    validate :prevent_last_primary_applicant_edit, on: :update, if: -> { role_changed? && role_changed_from_primary_applicant? && is_last_submission_primary_applicant? }

    # def self.role_by_user_and_submission(user:, submission:)
    #   return GrantSubmission::Applicant::ROLES[:primary] if user.system_admin?
    #   GrantSubmission::Applicant.find_by(submission: submission, user: user)&.role
    # end

    private

    def prevent_last_primary_applicant_edit
      errors.add(:base, 'There must be at least one primary applicant on the grant')
    end

    def prevent_last_primary_applicant_destroy
      errors.add(:base, 'This user\'s role cannot be deleted.')
      throw :abort
    end

    def is_last_submission_primary_applicant?
      submission.submission_permissions.role_primary.one?
    end

    def role_changed_from_primary_applicant?
      role_was == ROLES[:primary]
    end
  end
end