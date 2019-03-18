# frozen_string_literal: true
module PaperTrail
  class QuestionVersion < PaperTrail::Version
    self.table_name    = :question_versions
    self.sequence_name = :question_versions_id_seq
  end
end
