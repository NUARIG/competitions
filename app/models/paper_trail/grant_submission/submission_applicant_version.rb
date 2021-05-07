# frozen_string_literal: true

class PaperTrail::GrantSubmission::SubmissionApplicantVersion < PaperTrail::Version
  self.table_name    = :grant_submission_submission_applicant_versions
  self.sequence_name = :grant_submission_submission_applicant_versions_id_seq
end