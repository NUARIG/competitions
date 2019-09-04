# frozen_string_literal: true

class PaperTrail::CriteriaReviewVersion < PaperTrail::Version
  self.table_name    = :criteria_review_versions
  self.sequence_name = :criteria_review_versions_id_seq
end
