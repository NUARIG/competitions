require 'rails_helper'

RSpec.describe PaperTrail::GrantSubmission::FormVersion, type: :model, versioning: true do
  before(:each) do
    @grant       = create(:grant, :with_users_and_submission_form)
    @form        = @grant.form
  end

  context 'metadata' do
    it 'tracks grant_id' do
      expect(@form.versions.last.grant_id).to eql @grant.id
    end
  end
end
