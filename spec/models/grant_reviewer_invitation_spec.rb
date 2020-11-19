require 'rails_helper'

RSpec.describe GrantReviewer::Invitation, type: :model do
  let(:sys_admin)     { create(:user, :system_admin) }
  let(:user)          { create(:user, :grant_creator) }
  let(:invitation)    { create(:grant_reviewer_invitation) }

  let(:other_invite)  { create(:grant_reviewer_invitation) }

  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:inviter) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:reminded_at) }
  it { is_expected.to respond_to(:confirmed_at) }
  it { is_expected.to respond_to(:opted_out_at) }

  describe '#validations' do
    it 'validates a valid invitation' do
      expect(invitation).to be_valid
    end

    it 'allows system_administrator to invite' do
      invitation.inviter = sys_admin
      expect(invitation).to be_valid
    end

    describe 'invalid' do
      it 'requires an email address' do
        invitation.email = nil
        expect(invitation).not_to be_valid
        expect(invitation.errors).to include(:email)
      end

      it 'requires inviter to be on the grant' do
        invitation.inviter = user
        expect(invitation).not_to be_valid
        expect(invitation.errors).to include(:inviter)
        expect(invitation.errors.full_messages).to include 'Inviter does not have permission on this grant.'
      end
    end
  end

  describe '#scopes' do
    before(:each) do
      invitation.touch
    end

    context 'confirmed' do
      it 'excludes an unconfirmed invitation' do
        expect(GrantReviewer::Invitation.confirmed).not_to include invitation
      end

      it 'includes a confirmed invitation' do
        invitation.update(confirmed_at: Time.now)
        expect(GrantReviewer::Invitation.confirmed).to include invitation
      end

      context 'open' do
        it 'confirmed is not open' do
          invitation.update(confirmed_at: Time.now)
          expect(GrantReviewer::Invitation.open).not_to include invitation
        end
      end

    end

    context 'opted out' do
      it 'excludes an unconfirmed invitation' do
        expect(GrantReviewer::Invitation.opted_out).not_to include invitation
      end

      it 'includes a confirmed invitation' do
        invitation.update(opted_out_at: Time.now)
        expect(GrantReviewer::Invitation.opted_out).to include invitation
      end

      context 'open' do
        it 'opted_out is not open' do
          invitation.update(opted_out_at: Time.now)
          expect(GrantReviewer::Invitation.open).not_to include invitation
        end
      end
    end

    context 'by_grant' do
      before(:each) do
        other_invite.touch
      end

      it 'excludes an invitation for another grant' do
        grant_invitations = GrantReviewer::Invitation.by_grant(invitation.grant)
        expect(grant_invitations).to include invitation
        expect(grant_invitations).not_to include other_invite
      end
    end
  end
end
