class GrantReviewer::Invitation < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::GrantReviewerInvitationVersion'},
                  meta:     { grant_id: :grant_id, email: :email }

  belongs_to :grant
  belongs_to :inviter,  class_name: 'User',
                        foreign_key: :invited_by_id
  belongs_to :invitee,  class_name: 'User',
                        foreign_key: :invitee_id,
                        optional: true

  validates_presence_of   :email
  validates_uniqueness_of :email, scope: :grant, message: 'has already been invited.'
  validate :inviter_may_invite

  scope :by_invitee, -> (invitee) { where(invitee: invitee) }
  scope :by_email,   -> (email)   { where(email: email) }
  scope :by_grant,   -> (grant)   { where(grant_id: grant.id) }

  scope :confirmed,  -> { where.not(confirmed_at: nil) }
  scope :opted_out,  -> { where.not(opted_out_at: nil) }
  scope :open,       -> { where(confirmed_at: nil, opted_out_at: nil) }

  private

  def inviter_may_invite
    errors.add(:inviter, :must_have_grant_permission) unless inviter.system_admin? || grant.administrators.include?(inviter)
  end
end
