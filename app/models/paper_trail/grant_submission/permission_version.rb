# frozen_string_literal: true

class PaperTrail::GrantSubmission::PermissionVersion < PaperTrail::Version
  self.table_name    = :grant_submission_permission_versions
  self.sequence_name = :grant_submission_permission_versions_id_seq
end