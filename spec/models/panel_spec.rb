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

      it 'requires start_datetime to be after grant submission_close_date' do
        panel.start_datetime = panel.grant.submission_close_date - 1.hour
        expect(panel).not_to be_valid
        expect(panel.errors).to include(:start_datetime)
      end

      it 'require start_datetime if end_dateime is set' do
        panel.start_datetime = nil
        expect(panel).not_to be_valid
        expect(panel.errors).to include(:start_datetime)
      end

      it 'require end_datetime if start_dateime is set' do
        panel.end_datetime = nil
        expect(panel).not_to be_valid
        expect(panel.errors).to include(:start_datetime)
      end

      it 'does not require end_datetime and start_dateime to be set' do
        panel.start_datetime = nil
        panel.end_datetime = nil
        expect(panel).to be_valid
      end

    end
  end
end
