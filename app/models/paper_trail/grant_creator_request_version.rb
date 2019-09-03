# frozen_string_literal: true

class PaperTrail::GrantCreatorRequestVersion < PaperTrail::Version
  self.table_name    = :grant_creator_request_versions
  self.sequence_name = :grant_creator_request_versions_id_seq
end
