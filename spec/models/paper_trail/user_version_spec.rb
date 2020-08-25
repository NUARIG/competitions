require 'rails_helper'

RSpec.describe PaperTrail::UserVersion, type: :model, versioning: true do
  before(:each) do
    @user = create(random_user)
  end

  context 'metadata' do
    it 'tracks user_id' do
      expect(@user.versions.last.user_id).to eql @user.id
    end
  end
end
