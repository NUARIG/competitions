class PaperTrail::ConstraintQuestionVersion < PaperTrail::Version
  self.table_name    = :constraint_question_versions
  self.sequence_name = :constraint_question_versions_id_seq
end
