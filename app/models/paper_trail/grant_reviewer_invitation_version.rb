# frozen_string_literal: true

class PaperTrail::GrantReviewerInvitationVersion < PaperTrail::Version
  self.table_name    = :grant_reviewer_invitation_versions
  self.sequence_name = :grant_reviewer_invitation_versions_id_seq
end
