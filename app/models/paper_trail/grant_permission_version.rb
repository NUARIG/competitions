# frozen_string_literal: true

class PaperTrail::GrantPermissionVersion < PaperTrail::Version
  self.table_name    = :grant_permission_versions
  self.sequence_name = :grant_permission_versions_id_seq
end
