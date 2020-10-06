require 'rails_helper'

RSpec.describe Panel, type: :model do
  it { is_expected.to respond_to(:grant) }
  it { is_expected.to respond_to(:start_datetime) }
  it { is_expected.to respond_to(:end_datetime) }
  it { is_expected.to respond_to(:instructions) }
  it { is_expected.to respond_to(:meeting_link) }
  it { is_expected.to respond_to(:meeting_location) }

  let(:panel)         { create(:panel)          }
  let(:open_panel)    { create(:open_panel)     }
  let(:before_panel)  { create(:before_panel)   }
  let(:after_panel)   { create(:after_panel)    }
  let(:no_panel)      { create(:no_panel_dates) }

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
        expect(panel.errors.full_messages).to include('Start Date/Time is required if end is provided.')
      end

      it 'require end_datetime if start_dateime is set' do
        panel.end_datetime = nil
        expect(panel).not_to be_valid
        expect(panel.errors).to include(:end_datetime)
        expect(panel.errors.full_messages).to include('End Date/Time is required if start is provided.')
      end

      it 'does not require end_datetime and start_dateime to be set' do
        panel.start_datetime = nil
        panel.end_datetime = nil
        expect(panel).to be_valid
      end
    end

    context 'meeting_link' do
      it 'requires a valid secure url' do
        panel.meeting_link = 'invalid'
        expect(panel).not_to be_valid
        expect(panel.errors.full_messages).to include 'Meeting Link is not a valid secure URL.'
        panel.meeting_link = 'ftp://abc.com/'
        expect(panel).not_to be_valid
        expect(panel.errors.full_messages).to include 'Meeting Link is not a valid secure URL.'
        panel.meeting_link = 'http://abc.com/'
        expect(panel).not_to be_valid
        expect(panel.errors.full_messages).to include 'Meeting Link is not a valid secure URL.'
        panel.meeting_link = 'https://abc.com/'
        expect(panel).to be_valid
        panel.meeting_link = 'https://college.zoom.us/z/123456789'
        expect(panel).to be_valid
      end
    end
  end

  describe '#methods' do
    context '#is_open?' do
      context 'open panel' do
        it 'is true' do
          expect(open_panel.is_open?).to be true
        end
      end

      context 'before start_datetime' do
        it 'is false' do
          expect(before_panel.is_open?).to be false
        end
      end

      context 'after end_datetime' do
        it 'is false' do
          expect(after_panel.is_open?).to be false
        end
      end

      context 'no panel dates' do
        it 'is false' do
          expect(no_panel.is_open?).to be false
        end
      end
    end
  end
end
