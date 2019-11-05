# frozen_string_literal: true

class PaperTrail::BannerVersion < PaperTrail::Version
  self.table_name    = :banner_versions
  self.sequence_name = :banner_versions_id_seq
end