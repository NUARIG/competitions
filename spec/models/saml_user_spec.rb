# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SamlUser, type: :model do
  it { is_expected.to respond_to(:system_admin) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:grant_creator) }
  it { is_expected.to respond_to(:era_commons) }
  it { is_expected.to respond_to(:pending_reviewer_invitations) }

  let(:user)                { FactoryBot.build(:saml_user) }
  let(:other_user)          { create(:saml_user, era_commons: Faker::Lorem.characters(number: 10)) }
  let(:reviewer_invitation) { create(:grant_reviewer_invitation, email: user.email) }

  describe '#initiations' do
    it 'sets default of system_admin boolean' do
      expect(user.system_admin).to be(false)
    end

    it 'sets default of grant_creator boolean' do
      expect(user.grant_creator).to be(false)
    end
  end

  describe '#validations' do
    it 'validates presence of email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors).to include :email
    end

    it 'validates presence of first_name' do
      user.first_name = nil
      expect(user).not_to be_valid
      expect(user.errors).to include :first_name
    end

    it 'validates presence of last_name' do
      user.last_name = nil
      expect(user).not_to be_valid
      expect(user.errors).to include :last_name
    end

    it 'validates uniqueness of era_commons' do
      user.era_commons = other_user.era_commons
      expect(user).not_to be_valid
      expect(user.errors).to include :era_commons
    end
  end

  context 'reviewer invitations' do
    describe '#methods' do
      context 'set_pending_reviewer_invitations' do
        it 'has no pending_reviewer_invitations' do
          user.set_pending_reviewer_invitations
          expect(user.pending_reviewer_invitations.empty?).to be true
        end

        context 'with pending invitation' do
          it 'sets pending_reviewer_invitations' do
            reviewer_invitation.save
            user.set_pending_reviewer_invitations
            expect(user.pending_reviewer_invitations.empty?).to be false
          end
        end
      end

      context 'process_pending_reviewer_invitations' do
        before(:each) do
          reviewer_invitation.save
        end

        it 'confirms the reviewer_invitation' do
          expect(reviewer_invitation.confirmed_at.nil?).to be true
          user.save
          expect(reviewer_invitation.reload.confirmed_at.nil?).to be false
        end

        it 'creates the grant_reviewer' do
          expect do
            user.save
          end.to change{reviewer_invitation.grant.reviewers.count}.by(1)
        end
      end
    end
  end
end
