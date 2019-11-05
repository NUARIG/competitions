require 'rails_helper'

RSpec.describe Banner, type: :model do
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:visible) }

  let(:banner) { create(:banner) }

  describe '#validations' do
    it 'validates a valid banner' do
      expect(banner).to be_valid
    end

    it 'requires body text' do
      banner.body = nil
      expect(banner).not_to be_valid
      expect(banner.errors).to include(:body)
    end
  end
end
