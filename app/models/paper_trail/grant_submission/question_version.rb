# frozen_string_literal: true

class PaperTrail::GrantSubmission::QuestionVersion < PaperTrail::Version
  self.table_name    = :grant_submission_question_versions
  self.sequence_name = :grant_submission_question_versions_id_seq
end
