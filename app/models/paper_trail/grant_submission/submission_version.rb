# frozen_string_literal: true

class PaperTrail::GrantSubmission::SubmissionVersion < PaperTrail::Version
  self.table_name    = :grant_submission_submission_versions
  self.sequence_name = :grant_submission_submission_versions_id_seq
end
