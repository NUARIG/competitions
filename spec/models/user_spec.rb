# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to respond_to(:system_admin) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:first_name) }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to(:grant_creator) }

  let(:user) { FactoryBot.build(:user) }

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

    # pending
    # expect an auth gem to handle this
    it 'validates an email'
    it 'validate unique email'
  end
end
