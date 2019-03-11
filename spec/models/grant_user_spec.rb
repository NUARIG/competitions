# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantUser, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:user) }
  it { is_expected.to respond_to(:grant_role) }

  let(:organization) { FactoryBot.create(:organization) }
  let(:grant) { FactoryBot.create(:grant, organization_id: organization.id) }

  let(:admin_user) { FactoryBot.create(:user, organization_id: organization.id) }
  let(:editor_user) { FactoryBot.create(:user, organization_id: organization.id) }
  let(:viewer_user) { FactoryBot.create(:user, organization_id: organization.id) }

  let(:admin_grant_user) { FactoryBot.create(:admin_grant_user, grant_id: grant.id, user_id: admin_user.id) }
  let(:editor_grant_user) { FactoryBot.create(:editor_grant_user, grant_id: grant.id, user_id: editor_user.id) }
  let(:viewer_grant_user) { FactoryBot.create(:viewer_grant_user, grant_id: grant.id, user_id: viewer_user.id) }

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

    it 'allows only one role' do
    end

    it 'grant and user organizations match' do
    end
  end
end
