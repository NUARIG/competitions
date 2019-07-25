require 'rails_helper'

describe Grant::StatePolicy, type: :policy do
  subject { described_class.new(user, grant) }

  let (:grant) { create(:grant_with_users) }

  context 'with user having a role on the grant' do
    context 'grant admin user on the grant' do
      let(:user) { grant.grant_permissions.role_admin.first.user }

      it { is_expected.to permit_action(:update) }
    end

    context 'grant editor user on the grant' do
      let(:user) { grant.grant_permissions.role_editor.first.user }

      it { is_expected.to permit_action(:update) }
    end

    context 'grant viewer user on the grant' do
      let(:user) { grant.grant_permissions.role_viewer.first.user }

      it { is_expected.not_to permit_action(:update) }
    end
  end

  context 'with user not having a role on the grant' do
    context 'organization admin user' do
      let(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:update) }
    end

    context 'user' do
      let(:user) { create(:user) }

      it { is_expected.not_to permit_action(:update) }
    end
  end
end
