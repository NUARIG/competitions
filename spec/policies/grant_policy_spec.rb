require 'rails_helper'

describe GrantPolicy do
  context 'GRANT_ACCESS hash' do
    it 'accounts for possible GrantPermission::ROLES' do
      expect(GrantPolicy::GRANT_ACCESS.keys.sort == GrantPermission::ROLES.values.sort).to be true
    end
  end

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

        it 'allows grant admin allowed only public grants for index' do
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)

          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)
          expect(scope.to_a).not_to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_without_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_with_permission)
          expect(scope.to_a).not_to include(@completed_grant_without_permission)
          expect(scope.to_a).not_to include(@completed_grant_with_permission)
        end
      end

      context 'grant editor user on the grant' do
        let(:user) { @draft_grant_with_users_with_permission.grant_permissions.role_editor.first.user }

        let(:editor_admin1) { create(:editor_grant_permission, grant: @published_not_yet_open_grantwith_permission, user: user) }
        let(:editor_admin2) { create(:editor_grant_permission, grant: @published_open_grant_with_permission, user: user) }
        let(:editor_admin3) { create(:editor_grant_permission, grant: @published_closed_grant_with_permission , user: user) }
        let(:editor_admin4) { create(:editor_grant_permission, grant: @grant_with_users_with_permission, user: user) }
        let(:editor_admin5) { create(:editor_grant_permission, grant: @completed_grant_with_permission, user: user) }

        it 'allows grant editor allowed only public grants for index' do
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)

          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)
          expect(scope.to_a).not_to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_without_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_with_permission)
          expect(scope.to_a).not_to include(@completed_grant_without_permission)
          expect(scope.to_a).not_to include(@completed_grant_with_permission)
        end

      end

      context 'grant viewer user on the grant' do
        let(:user) { @draft_grant_with_users_with_permission.grant_permissions.role_viewer.first.user }

        let(:viewer_admin1) { create(:viewer_grant_permission, grant: @published_not_yet_open_grantwith_permission, user: user) }
        let(:viewer_admin2) { create(:viewer_grant_permission, grant: @published_open_grant_with_permission, user: user) }
        let(:viewer_admin3) { create(:viewer_grant_permission, grant: @published_closed_grant_with_permission , user: user) }
        let(:viewer_admin4) { create(:viewer_grant_permission, grant: @grant_with_users_with_permission, user: user) }
        let(:viewer_admin5) { create(:viewer_grant_permission, grant: @completed_grant_with_permission, user: user) }

        it 'allows grant editor allowed only public grants for index' do
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)

          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)
          expect(scope.to_a).not_to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_without_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_with_permission)
          expect(scope.to_a).not_to include(@completed_grant_without_permission)
          expect(scope.to_a).not_to include(@completed_grant_with_permission)
        end
      end
    end

    context 'with user not having a role on the grant' do
      context 'system_admin user' do
        let(:user) { create(:system_admin_user) }

        it 'allows system_admin access to all grants' do
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

        it 'grant editor allowed only public grants for index' do
          expect(scope.to_a).to include(@published_not_yet_open_grant_without_permission)
          expect(scope.to_a).to include(@published_not_yet_open_grant_with_permission)
          expect(scope.to_a).to include(@published_open_grant_without_permission)
          expect(scope.to_a).to include(@published_open_grant_with_permission)
          expect(scope.to_a).to include(@grant_with_users_without_permission)
          expect(scope.to_a).to include(@grant_with_users_with_permission)

          expect(scope.to_a).not_to include(@draft_grant_with_users_without_permission)
          expect(scope.to_a).not_to include(@draft_grant_with_users_with_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_without_permission)
          expect(scope.to_a).not_to include(@published_closed_grant_with_permission)
          expect(scope.to_a).not_to include(@completed_grant_without_permission)
          expect(scope.to_a).not_to include(@completed_grant_with_permission)
        end
      end
    end
  end

  context 'policy tests on restful actions besides index' do
    subject { described_class.new(user, grant)}
    let(:grant) { create(:published_open_grant_with_users) }

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
        it { is_expected.not_to forbid_action(:edit) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }

      end
    end

    context 'with user not having a role on the grant' do
      context 'system_admin user' do
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

  context 'time-sensitive show policy' do
    subject { described_class.new(user, grant)}

    context 'logged in user' do
      let(:user) { create(:user) }

      context 'grant closing today' do
        let(:grant) { create(:published_open_grant, submission_close_date: Date.today) }
        it { is_expected.to permit_action(:show) }
      end

      context 'grant opening today' do
        let(:grant) { create(:published_open_grant, submission_open_date: Date.today) }
        it { is_expected.to permit_action(:show) }
      end

      context 'grant published today' do
        let(:grant) { create(:published_open_grant, publish_date: Date.today) }
        it { is_expected.to permit_action(:show) }
      end

      context 'closed grant' do
        let(:grant) { create(:published_closed_grant)}
        it { is_expected.to forbid_action(:show) }
      end
    end

    context 'anonymous user' do
      let(:user) { nil }

      context 'grant closing today' do
        let(:grant) { create(:published_open_grant, submission_close_date: Date.today) }
        it { is_expected.to permit_action(:show) }
      end

      context 'grant opening today' do
        let(:grant) { create(:published_open_grant, submission_open_date: Date.today) }
        it { is_expected.to permit_action(:show) }
      end

      context 'grant published today' do
        let(:grant) { create(:published_open_grant, publish_date: Date.today) }
        it { is_expected.to permit_action(:show) }
      end

      context 'closed grant' do
        let(:grant) { create(:published_closed_grant)}
        it { is_expected.to forbid_action(:show) }
      end
    end

    context 'grant reviewer' do
      context 'closed grant' do
        let(:grant) { create(:open_grant_with_users_and_form_and_submission_and_reviewer, submission_close_date: Date.yesterday) }
        let(:user) { User.find(grant.grant_reviewers.first.reviewer_id)}

        it { is_expected.to permit_action(:show) }
      end
    end
  end
end
