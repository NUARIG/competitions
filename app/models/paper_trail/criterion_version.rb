# frozen_string_literal: true

class PaperTrail::CriterionVersion < PaperTrail::Version
  self.table_name    = :criterion_versions
  self.sequence_name = :criterion_versions_id_seq
end
