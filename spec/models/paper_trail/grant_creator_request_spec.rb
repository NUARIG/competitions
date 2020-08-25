require 'rails_helper'

RSpec.describe PaperTrail::GrantCreatorRequestVersion, type: :model, versioning: true do
  before(:each) do
    @user    = create(random_user)
    @request = create(:grant_creator_request, requester: @user)
  end

  context 'metadata' do
    it 'tracks requester_id' do
      expect(@request.versions.last.requester_id).to eql @user.id
    end
  end
end
