# frozen_string_literal: true

class PaperTrail::GrantSubmission::MultipleChoiceOptionVersion < PaperTrail::Version
  self.table_name    = :grant_submission_multiple_choice_option_versions
  self.sequence_name = :grant_submission_multiple_choice_option_versions_id_seq
end
