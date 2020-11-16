# frozen_string_literal: true

class PaperTrail::PanelVersion < PaperTrail::Version
  self.table_name     = :panel_versions
  self.sequence_name  = :panel_versions_id_seq
end
