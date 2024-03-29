# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantPermission, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:role) }
  it { is_expected.to respond_to(:submission_notification) }
  it { is_expected.to respond_to(:contact) }

  let(:grant)             { create(:grant) }

  let(:admin_user)        { create(:saml_user) }
  let(:editor_user)       { create(:saml_user) }
  let(:viewer_user)       { create(:saml_user) }

  let(:admin_user_with_submission_notification) { create(:saml_user) }

  let(:admin_grant_permission)  { build(:admin_grant_permission, grant_id: grant.id, user_id: admin_user.id) }
  let(:editor_grant_permission) { build(:editor_grant_permission, grant_id: grant.id, user_id: editor_user.id) }
  let(:viewer_grant_permission) { build(:viewer_grant_permission, grant_id: grant.id, user_id: viewer_user.id) }

  let(:admin_grant_permission_with_submission_notification) { build(:admin_grant_permission_with_submission_notification,
                                                                    grant_id: grant.id,
                                                                    user_id: admin_user_with_submission_notification.id)}
  describe '#validations' do
    it 'validates a valid grant_permission' do
      expect(admin_grant_permission).to be_valid
      expect(editor_grant_permission).to be_valid
      expect(viewer_grant_permission).to be_valid
      expect(admin_grant_permission_with_submission_notification).to be_valid
    end

    it 'requires a grant' do
      admin_grant_permission.grant = nil
      expect(admin_grant_permission).not_to be_valid
      expect(admin_grant_permission.errors).to include(:grant)
      admin_grant_permission.grant = grant
      expect(admin_grant_permission).to be_valid
    end

    it 'requires a user' do
      editor_grant_permission.user = nil
      expect(editor_grant_permission).not_to be_valid
      expect(editor_grant_permission.errors).to include(:user)
      editor_grant_permission.user = editor_user
      expect(editor_grant_permission).to be_valid
    end

    it 'requires a role' do
      viewer_grant_permission.role = nil
      expect(viewer_grant_permission).not_to be_valid
      expect(viewer_grant_permission.errors).to include(:role)
      viewer_grant_permission.role = 'viewer'
      expect(viewer_grant_permission).to be_valid
    end

    it 'prevents deletion of last admin' do
      admin_grant_permission.save
      viewer_grant_permission.save
      viewer_grant_permission.update(role: 'admin')
      expect{viewer_grant_permission.destroy}.to change{grant.grant_permissions.count}.by -1
      expect{admin_grant_permission.destroy}.not_to change{grant.grant_permissions.count}
    end

  end
end
