require 'rails_helper'

describe GrantSubmission::FormPolicy, type: :policy do
  subject { described_class.new(user, form) }

  let(:grant) { create(:grant_with_users) }
  let(:form) { grant.form }

  context 'with user having a role on the grant' do
    context 'grant admin user on the grant' do
      let(:user) { grant.grant_permissions.role_admin.first.user }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update_fields) }
      it { is_expected.to permit_action(:export) }
      it { is_expected.to permit_action(:import) }
    end

    context 'grant editor user on the grant' do
      let(:user) { grant.grant_permissions.role_editor.first.user }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update_fields) }
      it { is_expected.to permit_action(:export) }
      it { is_expected.to permit_action(:import) }
    end

    context 'grant viewer user on the grant' do
      let(:user) { grant.grant_permissions.role_viewer.first.user }

      it { is_expected.not_to permit_action(:update) }
      it { is_expected.to permit_action(:edit) } # fields disabled for viewer
      it { is_expected.not_to permit_action(:update_fields) }
      it { is_expected.not_to permit_action(:export) }
      it { is_expected.not_to permit_action(:import) }
    end
  end

  context 'with user not having a role on the grant' do
    context 'system_admin user' do
      let(:user) { create(:system_admin_saml_user) }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:update_fields) }
      it { is_expected.to permit_action(:export) }
      it { is_expected.to permit_action(:import) }
    end

    context 'user' do
      let(:user) { create(:saml_user) }

      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:update_fields) }
      it { is_expected.not_to permit_action(:export) }
      it { is_expected.not_to permit_action(:import) }
    end
  end
end
