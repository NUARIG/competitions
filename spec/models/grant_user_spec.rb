# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantUser, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:grant_role) }
  it { is_expected.to respond_to(:deleted_at) }

  let(:organization)      { create(:organization) }
  let(:grant)             { create(:grant, organization_id: organization.id) }

  let(:admin_user)        { create(:user, organization_id: organization.id) }
  let(:editor_user)       { create(:user, organization_id: organization.id) }
  let(:viewer_user)       { create(:user, organization_id: organization.id) }

  let(:admin_grant_user)  { build(:admin_grant_user, grant_id: grant.id, user_id: admin_user.id) }
  let(:editor_grant_user) { build(:editor_grant_user, grant_id: grant.id, user_id: editor_user.id) }
  let(:viewer_grant_user) { build(:viewer_grant_user, grant_id: grant.id, user_id: viewer_user.id) }

  describe '#validations' do
    it 'validates a valid grant_user' do
      expect(admin_grant_user).to be_valid
      expect(editor_grant_user).to be_valid
      expect(viewer_grant_user).to be_valid
    end

    it 'requires a grant' do
      admin_grant_user.grant = nil
      expect(admin_grant_user).not_to be_valid
      expect(admin_grant_user.errors).to include(:grant)
      admin_grant_user.grant = grant
      expect(admin_grant_user).to be_valid
    end

    it 'requires a user' do
      editor_grant_user.user = nil
      expect(editor_grant_user).not_to be_valid
      expect(editor_grant_user.errors).to include(:user)
      editor_grant_user.user = editor_user
      expect(editor_grant_user).to be_valid
    end

    it 'requires a grant_role' do
      viewer_grant_user.grant_role = nil
      expect(viewer_grant_user).not_to be_valid
      expect(viewer_grant_user.errors).to include(:grant_role)
      viewer_grant_user.grant_role = 'viewer'
      expect(viewer_grant_user).to be_valid
    end

    it 'prevents deletion of last admin' do
      admin_grant_user.save
      viewer_grant_user.save
      viewer_grant_user.update_attributes(grant_role: 'admin')
      expect{viewer_grant_user.destroy}.to change{grant.grant_users.count}.by -1
      expect{admin_grant_user.destroy}.not_to change{grant.grant_users.count}
    end

  end
end
