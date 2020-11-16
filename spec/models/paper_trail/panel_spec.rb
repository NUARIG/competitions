require 'rails_helper'

RSpec.describe PaperTrail::PanelVersion, type: :model, versioning: true do
  let!(:panel) { create(:panel) }

  context 'metadata' do
    it 'tracks grant_id' do
      expect(PaperTrail::PanelVersion.last.grant_id).to eql panel.grant_id
    end
  end
end
