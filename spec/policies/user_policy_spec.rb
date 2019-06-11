# frozen_string_literal: true

require 'rails_helper'

# The below specs are only testing update and edit for thieir own records.
# Feature specs will need to be used to test editing records other than the user's.
describe UserPolicy do
  context 'policy scope tests on index' do
    let(:scope) { Pundit.policy_scope!(user, User) }

    subject { described_class.new(user, user)}

    before(:each) do
      @other_user = create(:user)
    end

    context 'with user having a role on the grant' do
      let(:grant) { create(:grant_with_users) }

      context 'grant admin user on the grant' do
        let(:user) { grant.grant_permissions.role_admin.first.user }

        it 'allows user to see own record' do
          expect(scope.to_a).to include(user)
          expect(scope.to_a).not_to include(@other_user)
        end
      end

      context 'grant editor user on the grant' do
        let(:user) { grant.grant_permissions.role_editor.first.user }

        it 'allows user to see own record' do
          expect(scope.to_a).to include(user)
          expect(scope.to_a).not_to include(@other_user)
        end
      end

      context 'grant viewer user on the grant' do
        let(:user) { grant.grant_permissions.role_viewer.first.user }

        it 'allows user to see own record' do
          expect(scope.to_a).to include(user)
          expect(scope.to_a).not_to include(@other_user)
        end
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
        let(:user) { create(:organization_admin_user) }

        it 'allows user to see own record' do
          expect(scope.to_a).to include(user)
          expect(scope.to_a).to include(@other_user)
        end
      end

      context 'user' do
        let(:user) { create(:user) }

        it 'allows user to see own record' do
          expect(scope.to_a).to include(user)
          expect(scope.to_a).not_to include(@other_user)
        end
      end
    end
  end

  context 'policy tests on restful actions besides index' do
    subject { described_class.new(user, user)}

    context 'with user having a role on the grant' do
      let(:grant) { create(:grant_with_users) }

      context 'grant admin user on the grant' do
        let(:user) { grant.grant_permissions.role_admin.first.user }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
      end

      context 'grant editor user on the grant' do
        let(:user) { grant.grant_permissions.role_editor.first.user }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
      end

      context 'grant viewer user on the grant' do
        let(:user) { grant.grant_permissions.role_viewer.first.user }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
      end
    end

    context 'with user not having a role on the grant' do
      context 'organization admin user' do
        let(:user) { create(:organization_admin_user) }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
      end

      context 'user' do
        let(:user) { create(:user) }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:edit) }
        it { is_expected.to permit_action(:update) }
      end
    end
  end
end
