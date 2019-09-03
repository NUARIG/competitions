# frozen_string_literal: true

class PaperTrail::ReviewVersion < PaperTrail::Version
  self.table_name    = :review_versions
  self.sequence_name = :review_versions_id_seq
end
