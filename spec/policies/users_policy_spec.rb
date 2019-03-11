# frozen_string_literal: true

require 'rails_helper'

# The below specs are only testing update and edit for thieir own records.
# Feature specs will need to be used to test editing records other than the user's.
describe UserPolicy do
  subject { described_class.new(user, user) }

  context 'with user and grant of the same organization' do
    let(:organization) { FactoryBot.create(:organization) }

    context 'grants for organization none users' do
      let(:user) { FactoryBot.create(:user, organization: organization) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }

      it { is_expected.to forbid_action(:index) }
    end

    context 'grants for organization viewer users' do
      let(:user) { FactoryBot.create(:user, organization_role: 'viewer', organization: organization) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context 'grants for organization editor users' do
      let(:user) { FactoryBot.create(:user, organization_role: 'editor', organization: organization) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end

    context 'grants for organization admin users' do
      let(:user) { FactoryBot.create(:user, organization_role: 'admin', organization: organization) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
    end
  end
end
