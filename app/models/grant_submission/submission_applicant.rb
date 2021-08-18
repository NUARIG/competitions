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

    validates :applicant, uniqueness: { scope: :submission }

    private

    def prevent_last_applicant_destroy
      errors.add(:base, 'There must be at least one applicant on the submission')
      throw :abort
    end

    def is_last_applicant?
      submission.applicants.one?
    end
  end
end