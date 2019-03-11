# frozen_string_literal: true

class PaperTrail::GrantVersion < PaperTrail::Version
  self.table_name    = :grant_versions
  self.sequence_name = :grant_versions_id_seq
end
