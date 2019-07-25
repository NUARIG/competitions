require 'rails_helper'

describe GrantPolicy do
  # This file only tests the permissions based on role in pundit.
  # Permissions based on state changes are handled in system specs.
  # TODO: implement the system specs to test state changes.

  context 'policy scope tests on index' do
    let(:scope) { Pundit.policy_scope!(user, Grant) }

    before(:each) do
      @draft_grant_with_users_without_permission        = create(:draft_grant)
      @draft_grant_with_users_with_permission           = create(:draft_grant_with_users)

      @published_not_yet_open_grant_without_permission  = create(:published_not_yet_open_grant)
      @published_not_yet_open_grant_with_permission     = create(:published_not_yet_open_grant_with_users)

      @published_open_grant_without_permission          = create(:published_open_grant)
      @published_open_grant_with_permission             = create(:published_open_grant_with_users)

      @published_closed_grant_without_permission        = create(:published_closed_grant)
      @published_closed_grant_with_permission           = create(:published_closed_grant_with_users)

      @grant_with_users_without_permission              = create(:grant_with_users)
      @grant_with_users_with_permission                 = create(:grant_with_users)

      @completed_grant_without_permission               = create(:completed_grant)
      @completed_grant_with_permission                  = create(:completed_grant_with_users)
    end

    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
        let(:user) { @draft_grant_with_users_with_permission.grant_permissions.role_admin.first.user }

        let(:grant_admin1) { create(:admin_grant_permission, grant: @published_not_yet_open_grantwith_permission, user: user) }
        let(:grant_admin2) { create(:admin_grant_permission, grant: @published_open_grant_with_permission, user: user) }
        let(:grant_admin3) { create(:admin_grant_permission, grant: @published_closed_grant_with_permission, user: user) }
        let(:grant_admin4) { create(:admin_grant_permission, grant: @grant_with_users_with_permission, user: user) }
        let(:grant_admin5) { create(:admin_grant_permission, grant: @completed_grant_with_permission, user: user) }

        it 'allows grant admin subset limited to permitted grants' do
          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)

          expect(scope.to_a).to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@published_closed_grant_without_permission)
          expect(scope.to_a).to include(@published_closed_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)
          expect(scope.to_a).to include(@completed_grant_without_permission)
          expect(scope.to_a).to include(@completed_grant_with_permission)
        end
      end

      context 'grant editor user on the grant' do
        let(:user) { @draft_grant_with_users_with_permission.grant_permissions.role_editor.first.user }

        let(:editor_admin1) { create(:editor_grant_permission, grant: @published_not_yet_open_grantwith_permission, user: user) }
        let(:editor_admin2) { create(:editor_grant_permission, grant: @published_open_grant_with_permission, user: user) }
        let(:editor_admin3) { create(:editor_grant_permission, grant: @published_closed_grant_with_permission , user: user) }
        let(:editor_admin4) { create(:editor_grant_permission, grant: @grant_with_users_with_permission, user: user) }
        let(:editor_admin5) { create(:editor_grant_permission, grant: @completed_grant_with_permission, user: user) }

        it 'allows grant editor subset limited to permitted grants' do
          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)

          expect(scope.to_a).to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@published_closed_grant_without_permission)
          expect(scope.to_a).to include(@published_closed_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)
          expect(scope.to_a).to include(@completed_grant_without_permission)
          expect(scope.to_a).to include(@completed_grant_with_permission)
        end

      end

      context 'grant viewer user on the grant' do
        let(:user) { @draft_grant_with_users_with_permission.grant_permissions.role_viewer.first.user }

        let(:viewer_admin1) { create(:viewer_grant_permission, grant: @published_not_yet_open_grantwith_permission, user: user) }
        let(:viewer_admin2) { create(:viewer_grant_permission, grant: @published_open_grant_with_permission, user: user) }
        let(:viewer_admin3) { create(:viewer_grant_permission, grant: @published_closed_grant_with_permission , user: user) }
        let(:viewer_admin4) { create(:viewer_grant_permission, grant: @grant_with_users_with_permission, user: user) }
        let(:viewer_admin5) { create(:viewer_grant_permission, grant: @completed_grant_with_permission, user: user) }

        it 'allows grant editor subset limited to permitted grants' do
          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)

          expect(scope.to_a).to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@published_closed_grant_without_permission)
          expect(scope.to_a).to include(@published_closed_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)
          expect(scope.to_a).to include(@completed_grant_without_permission)
          expect(scope.to_a).to include(@completed_grant_with_permission)
        end
      end
    end

    context 'with user not having a role on the grant' do

      context 'organization admin user' do
        let(:user) { create(:system_admin_user) }

        it 'allows organization grant all grants' do
          expect(scope.to_a).to include(@draft_grant_with_users_without_permission)
          expect(scope.to_a).to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@published_closed_grant_without_permission)
          expect(scope.to_a).to include(@published_closed_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)
          expect(scope.to_a).to include(@completed_grant_without_permission)
          expect(scope.to_a).to include(@completed_grant_with_permission)
        end
      end

      context 'user' do
        let(:user) { create(:user) }

        it 'allows grant editor subset limited to permitted grants' do
          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)
          expect(scope.to_a).not_to include(@draft_grant_with_users_with_permission)

          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@published_closed_grant_without_permission)
          expect(scope.to_a).to include(@published_closed_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)
          expect(scope.to_a).to include(@completed_grant_without_permission)
          expect(scope.to_a).to include(@completed_grant_with_permission)
        end
      end
    end
  end

  context 'policy tests on restful actions besides index' do
    subject { described_class.new(user, grant)}
    let(:grant) { create(:open_grant_with_users) }

    context 'with user having a role on the grant' do
      context 'grant admin user on the grant' do
        let(:user) { grant.grant_permissions.role_admin.first.user }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:new) }
        it { is_expected.to permit_action(:create) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
        it { is_expected.to permit_action(:destroy) }
      end

      context 'grant editor user on the grant' do
        let(:user) { grant.grant_permissions.role_editor.first.user }

        it { is_expected.to permit_action(:show) }
        it { is_expected.not_to permit_action(:new) }
        it { is_expected.not_to permit_action(:create) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }

        it { is_expected.to forbid_action(:destroy) }

      end

      context 'grant viewer user on the grant' do
        let(:user) { grant.grant_permissions.role_viewer.first.user }

        it { is_expected.to permit_action(:show) }

        it { is_expected.to forbid_action(:new) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }

      end
    end

    context 'with user not having a role on the grant' do

      context 'organization admin user' do
        let(:user) { create(:system_admin_user) }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:new) }
        it { is_expected.to permit_action(:create) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
        it { is_expected.to permit_action(:destroy) }
      end

      context 'user' do
        let(:user) { create(:user) }

        it { is_expected.to permit_action(:show) }

        it { is_expected.to forbid_action(:new) }
        it { is_expected.to forbid_action(:edit) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end
    end
  end
end
