# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegisteredUser, type: :model do
  it { is_expected.to respond_to(:system_admin) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:grant_creator) }
  it { is_expected.to respond_to(:era_commons) }

  let(:user)       { FactoryBot.build(:registered_user) }
  let(:other_user) { create(:registered_user, era_commons: Faker::Lorem.characters(number: 10)) }

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

    it 'checks for restricted domains' do
      user.email = 'dummy@space.space'
      expect(user).not_to be_valid
      expect(user.errors).to include :email
      expect(user.errors.messages[:email]).to eq ['domain is blocked from registering.']

    end

    it 'checks for saml email domains' do
      user.email = 'dummy@blocked_email.edu'
      expect(user).not_to be_valid
      expect(user.errors).to include :email
      expect(user.errors.messages[:email]).to eq ['Please log in with your institutional ID.']
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

    # pending
    # expect an auth gem to handle this
    it 'validates an email'
    it 'validate unique email'
  end
end
