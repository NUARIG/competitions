# frozen_string_literal: true

class PaperTrail::GrantSubmission::SectionVersion < PaperTrail::Version
  self.table_name    = :grant_submission_section_versions
  self.sequence_name = :grant_submission_section_versions_id_seq
end
