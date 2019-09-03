# frozen_string_literal: true

class PaperTrail::GrantSubmission::FormVersion < PaperTrail::Version
  self.table_name    = :grant_submission_form_versions
  self.sequence_name = :grant_submission_form_versions_id_seq
end
