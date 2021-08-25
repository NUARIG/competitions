# frozen_string_literal: true

module GrantSubmission
  class SubmissionApplicant < ApplicationRecord
    self.table_name = 'grant_submission_submission_applicants'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::SubmissionApplicantVersion' },
                    meta:     { grant_submission_submission_id: :grant_submission_submission_id,
                                applicant_id: :applicant_id }

    belongs_to :submission,   class_name: 'GrantSubmission::Submission',
                              foreign_key: 'grant_submission_submission_id',
                              inverse_of: :submission_applicants
    belongs_to :applicant,    class_name: 'User',
                              foreign_key: :applicant_id,
                              inverse_of: :submission_applicants

    before_destroy :prevent_last_applicant_destroy, if: -> { is_last_applicant? }

    validates :submission,  presence: true
    validates :applicant,   presence: true

    validate :prevent_creation_of_existing_applicant, if: -> () { applicant_already_exists? }
    # validates :applicant, uniqueness: { scope: :submission }

    private

    def applicant_already_exists?
      GrantSubmission::SubmissionApplicant.where(submission: submission).where(applicant: applicant).any?
    end

    def prevent_creation_of_existing_applicant
      errors.add(:base, I18n.t('activerecord.errors.models.grant_submission/submission_applicant.attributes.applicant.taken',
                                submission_title: submission.title,
                                applicant_name: ApplicationController.helpers.full_name(self.applicant)))
      throw :abort
    end

    def prevent_last_applicant_destroy
      errors.add(:base, 'There must be at least one applicant on the submission')
      throw :abort
    end

    def is_last_applicant?
      submission.applicants.one?
    end
  end
end