# frozen_string_literal: true

class PaperTrail::GrantSubmission::ResponseVersion < PaperTrail::Version
  self.table_name    = :grant_submission_response_versions
  self.sequence_name = :grant_submission_response_versions_id_seq
end
