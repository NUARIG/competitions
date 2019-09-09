# frozen_string_literal: true

class PaperTrail::GrantSubmission::ResponseVersion < PaperTrail::Version
  before_create :set_grant_submission_question_id

  self.table_name    = :grant_submission_response_versions
  self.sequence_name = :grant_submission_response_versions_id_seq

  # 9/5/19 - Fixes empty metadata column on ActiveStorage-related updates
  def set_grant_submission_question_id
    self.grant_submission_question_id ||= object_deserialized['grant_submission_question_id']
  end
end
