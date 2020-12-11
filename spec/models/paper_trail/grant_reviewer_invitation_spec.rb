require 'rails_helper'

RSpec.describe PaperTrail::GrantReviewerInvitationVersion, type: :model, versioning: true do
  let!(:invitation) { create(:grant_reviewer_invitation) }
  let(:grant)       { invitation.grant }
  let(:inviter)     { invitation.inviter }

  context 'metadata' do
    it 'tracks grant' do
      expect(invitation.versions.last.grant_id).to eql grant.id
    end

    it 'tracks email' do
      expect(invitation.versions.last.email).to eql invitation.email
    end
  end
end
