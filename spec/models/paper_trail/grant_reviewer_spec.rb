require 'rails_helper'

RSpec.describe PaperTrail::GrantReviewerVersion, type: :model, versioning: true do
  before(:each) do
    @grant          = create(:grant)
    @reviewer       = create(random_user)
    @grant_reviewer = create(:grant_reviewer, grant: @grant,
                                              reviewer: @reviewer)
  end

  context 'metadata' do
    it 'tracks grant_id' do
      expect(@grant_reviewer.versions.last.grant_id).to eql @grant.id
    end

    it 'tracks reviewer_id' do
      expect(@grant_reviewer.versions.last.reviewer_id).to eql @reviewer.id
    end
  end
end
