# frozen_string_literal: true

class PaperTrail::GrantReviewerVersion < PaperTrail::Version
  self.table_name    = :grant_reviewer_versions
  self.sequence_name = :grant_reviewer_versions_id_seq
end
