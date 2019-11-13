require 'rails_helper'

RSpec.describe PaperTrail::GrantPermissionVersion, type: :model, versioning: true do
  before(:each) do
    @grant            = create(:grant, :with_users_and_submission_form)
    @grant_permission = @grant.grant_permissions.first
    @admin            = @grant.editors.first
  end

  context 'metadata' do
    it 'tracks grant_id' do
      expect(@grant_permission.versions.last.grant_id).to eql @grant.id
    end

    it 'tracks the editor\'s user_id' do
      expect(@grant_permission.versions.last.user_id).to eql @admin.id
    end
  end
end
