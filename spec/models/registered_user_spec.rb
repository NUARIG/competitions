# frozen_string_literal: true

require 'rails_helper'
include UsersHelper

RSpec.shared_examples "a restricted domain" do
  describe "restricted_domain_email" do
    it 'checks for restricted domains' do
      user.email = restricted_domain_email
      expect(user).not_to be_valid
      expect(user.errors).to include :email
      expect(user.errors.messages[:email]).to eq ['domain is blocked from registering.']
    end
  end
end


RSpec.describe RegisteredUser, type: :model do
  it { is_expected.to respond_to(:system_admin) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:grant_creator) }
  it { is_expected.to respond_to(:era_commons) }

  let(:user)       { FactoryBot.build(:registered_user) }
  let(:other_user) { create(:registered_user, era_commons: Faker::Lorem.characters(number: 10)) }
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
    describe 'checks for restricted domains in email' do
      it_behaves_like 'a restricted domain' do
        let(:restricted_domain_email) { 'dummy@email.xyz' }
      end

      it_behaves_like 'a restricted domain' do
        let(:restricted_domain_email) { 'dummy@email.top' }
      end

      it_behaves_like 'a restricted domain' do
        let(:restricted_domain_email) { 'dummy@email.website' }
      end

      it_behaves_like 'a restricted domain' do
        let(:restricted_domain_email) { 'dummy@email.space' }
      end

      it_behaves_like 'a restricted domain' do
        let(:restricted_domain_email) { 'dummy@email.online' }
      end
    end

    it 'checks for saml email domains' do
      user.email = 'dummy@blocked_email.edu'
      expect(user).not_to be_valid

      expect(user.errors).to include :saml_email
      # TODO: check for link in error message
      expect(user.errors).to include :email
      expect(user.errors.messages[:email]).to include I18n.t('activerecord.errors.models.registered_user.attributes.email.saml_email_invalid')
    end

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

    describe 'first_name format validation' do
      it 'accepts valid names with letters and common punctuation' do
        valid_names = ['John', 'Mary-Jane', "D'Angelo", 'José', 'François', 'Müller', 'J. Thomas']
        valid_names.each do |name|
          user.first_name = name
          expect(user).to be_valid, "Expected '#{name}' to be valid"
        end
      end

      it 'rejects names with underscores' do
        user.first_name = 'bingo_was_name_fmcmfvyl'
        expect(user).not_to be_valid
        expect(user.errors).to include :first_name
        expect(user.errors.messages[:first_name]).to include 'can only contain letters, spaces, hyphens, and apostrophes.'
      end

      it 'rejects names with special characters and injection patterns' do
        invalid_names = ['${injection}', 'name<tag>', 'john#smith', 'joe&mary', 'name%symbol', 'test{brace}']
        invalid_names.each do |name|
          user.first_name = name
          expect(user).not_to be_valid, "Expected '#{name}' to be invalid"
          expect(user.errors).to include :first_name
        end
      end

      it 'rejects names with numbers' do
        user.first_name = 'john123'
        expect(user).not_to be_valid
        expect(user.errors).to include :first_name
      end

      it 'rejects names exceeding 50 characters' do
        user.first_name = 'A' * 51
        expect(user).not_to be_valid
        expect(user.errors).to include :first_name
      end

      it 'accepts names with exactly 50 characters' do
        user.first_name = 'A' * 50
        expect(user).to be_valid
      end

      it 'rejects single-letter names' do
        invalid_first_names = ['J.', 'J']
        invalid_first_names.each do |name|
          user.first_name = name
          expect(user).not_to be_valid, "Expected '#{name}' to be invalid"
          expect(user.errors).to include :first_name
        end
      end

      it 'accepts two-letter names' do
        user.first_name = 'Jo'
        expect(user).to be_valid
      end

      it 'rejects names with leading spaces' do
        user.first_name = ' John'
        expect(user).not_to be_valid
        expect(user.errors).to include :first_name
      end

      it 'rejects names with trailing spaces' do
        user.first_name = 'John '
        expect(user).not_to be_valid
        expect(user.errors).to include :first_name
      end
    end

    describe 'last_name format validation' do
      it 'accepts valid names with letters and common punctuation' do
        valid_names = ['Smith', 'O\'Brien', 'Müller-Koch', 'García', 'François']
        valid_names.each do |name|
          user.last_name = name
          expect(user).to be_valid, "Expected '#{name}' to be valid"
        end
      end

      it 'rejects names with underscores' do
        user.last_name = '${${env:NaN:-j}ndi${env:NaN:-:}'
        expect(user).not_to be_valid
        expect(user.errors).to include :last_name
        expect(user.errors.messages[:last_name]).to include 'can only contain letters, spaces, hyphens, and apostrophes.'
      end

      it 'rejects names with special characters and injection patterns' do
        invalid_names = ['${injection}', 'name<tag>', 'smith#name', 'last&first', 'name%char']
        invalid_names.each do |name|
          user.last_name = name
          expect(user).not_to be_valid, "Expected '#{name}' to be invalid"
          expect(user.errors).to include :last_name
        end
      end

      it 'rejects names with numbers' do
        user.last_name = 'smith456'
        expect(user).not_to be_valid
        expect(user.errors).to include :last_name
      end

      it 'rejects names exceeding 50 characters' do
        user.last_name = 'A' * 51
        expect(user).not_to be_valid
        expect(user.errors).to include :last_name
      end

      it 'accepts names with exactly 50 characters' do
        user.last_name = 'A' * 50
        expect(user).to be_valid
      end

      it 'rejects single-letter names' do
        user.last_name = 'S'
        expect(user).not_to be_valid
        expect(user.errors).to include :last_name
      end

      it 'accepts two-letter names' do
        user.last_name = 'Li'
        expect(user).to be_valid
      end

      it 'rejects names with leading spaces' do
        user.last_name = ' Smith'
        expect(user).not_to be_valid
        expect(user.errors).to include :last_name
      end

      it 'rejects names with trailing spaces' do
        user.last_name = 'Smith '
        expect(user).not_to be_valid
        expect(user.errors).to include :last_name
      end
    end
  end

  context 'reviewer invitations' do
    describe '#methods' do
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

        it 'confirms the user' do
          user.save
          expect(user.confirmed_at).not_to be nil
        end
      end
    end
  end
end
