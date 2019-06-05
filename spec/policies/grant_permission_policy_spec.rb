require 'rails_helper'
describe GrantPermissionPolicy do

  subject { described_class.new(user, grant_permissions) }

  before(:each) do
    @grant = create(:grant_with_users)
  end

  let(:grant_permissions) { @grant.grant_permissions }

  context 'with user having a role on the grant' do
    context 'grant admin user on the grant' do
      let(:user) { @grant.grant_permissions.role_admin.first.user }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'grant editor user on the grant' do
      let(:user) { @grant.grant_permissions.role_editor.first.user }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'grant viewer user on the grant' do
      let(:user) { @grant.grant_permissions.role_viewer.first.user }

      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end

  context 'with user not having a role on the grant' do
    context 'organization admin user' do
      let(:user) { create(:organization_admin_user) }

      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'user' do
      let(:user) { create(:user) }

      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end
end
