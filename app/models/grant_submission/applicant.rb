# frozen_string_literal: true

module GrantSubmission
  class Applicant < ApplicationRecord
    self.table_name = 'grant_submission_applicants'
    has_paper_trail versions: { class_name: 'PaperTrail::GrantSubmission::ApplicantVersion' },
                    meta:     { grant_submission_submission_id: :grant_submission_submission_id,
                                user_id: :user_id }

    belongs_to :submission,   class_name: 'GrantSubmission::Submission',
                              foreign_key: 'grant_submission_submission_id',
                              inverse_of: :applicants
    belongs_to :user

    before_destroy :prevent_last_applicant_destroy, if: -> { is_last_applicant? }

    validates :submission,  presence: true
    validates :user,        presence: true

    private

    def prevent_last_applicant_destroy
      errors.add(:base, 'There must be at least one applicant on the grant')
      throw :abort
    end

    def is_last_applicant?
      submission.applicants.one?
    end
  end
end