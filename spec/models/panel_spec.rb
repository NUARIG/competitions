require 'rails_helper'

RSpec.describe Panel, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:start_datetime) }
  it { is_expected.to respond_to(:end_datetime) }
  it { is_expected.to respond_to(:instructions) }
  it { is_expected.to respond_to(:meeting_link) }
  it { is_expected.to respond_to(:meeting_location) }

  let(:panel) { create(:panel) }

  describe '#validations' do
    it 'validates a valid panel' do
      expect(panel).to be_valid
    end

    it 'requires a unique grant' do
      invalid_panel = build(:panel, grant: panel.grant)
      expect(invalid_panel).not_to be_valid
      expect(invalid_panel.errors).to include :grant
    end

    context 'dates' do
      it 'requires start_datetime to be before end_datetime' do
        panel.start_datetime  = 2.days.from_now
        panel.end_datetime    = 1.days.from_now
        expect(panel).not_to be_valid
        expect(panel.errors).to include(:start_datetime)
      end
    end
  end
end
