# frozen_string_literal: true

class PaperTrail::UserVersion < PaperTrail::Version
  self.table_name    = :user_versions
  self.sequence_name = :user_versions_id_seq
end
