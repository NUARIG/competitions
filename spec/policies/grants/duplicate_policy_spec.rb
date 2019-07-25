require 'rails_helper'
# RSpec.describe Admin::PostsController, :type => :controller do

describe Grant::DuplicatePolicy, type: :policy do
  subject { described_class.new(user, grant) }

  let (:grant) { create(:grant_with_users) }

  context 'with user having a role on the grant' do
    context 'grant admin user on the grant' do
      let(:user) { grant.grant_permissions.role_admin.first.user }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
    end

    context 'grant editor user on the grant' do
      let(:user) { grant.grant_permissions.role_editor.first.user }

      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
    end

    context 'grant viewer user on the grant' do
      let(:user) { grant.grant_permissions.role_viewer.first.user }

      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
    end
  end

  context 'with user not having a role on the grant' do
    context 'organization admin user' do
      let(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:create) }
    end

    context 'grant creator user' do
      let(:user) { create(:grant_creator_user) }

      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
    end

    context 'user' do
      let(:user) { create(:user) }

      it { is_expected.not_to permit_action(:new) }
      it { is_expected.not_to permit_action(:create) }
    end
  end
end
