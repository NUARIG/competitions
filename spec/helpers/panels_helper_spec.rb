require 'rails_helper'

RSpec.describe PanelsHelper, type: :helper do
  context 'panel is not today' do
    let(:panel) { create(:panel) }

    context 'will_close_at_string' do
      it 'includes date in string' do
        will_close_at_string = will_close_at_string(panel: panel)
        expect(will_close_at_string).to include time_portion(panel: panel, which_date: 'end') # include panel.end_datetime.strftime('%l:%M%P')
        expect(will_close_at_string).to include date_portion(panel: panel, which_date: 'end') # include "on #{panel.end_datetime.strftime('%-m/%-d/%Y')}"
      end
    end

    context 'will_open_at_string' do
      it 'includes date in string' do
        will_open_at_string = will_open_at_string(panel: panel)
        expect(will_open_at_string).to include time_portion(panel: panel, which_date: 'start') # include panel.start_datetime.strftime('%l:%M%P')
        expect(will_open_at_string).to include date_portion(panel: panel, which_date: 'start') # include "on #{panel.start_datetime.strftime('%-m/%-d/%Y')}"
      end
    end
  end

  context 'panel is today' do
    let(:panel) { create(:open_panel, start_datetime: 1.minute.ago,
                                      end_datetime: 1.minute.from_now) }

    context 'will_close_at_string' do
      it 'does not include date in string' do
        will_close_at_string = will_close_at_string(panel: panel)
        expect(will_close_at_string).to include time_portion(panel: panel, which_date: 'end') # include panel.end_datetime.strftime('%l:%M%P')
        expect(will_close_at_string).not_to include date_portion(panel: panel, which_date: 'end') # include "on #{panel.end_datetime.strftime('%-m/%-d/%Y')}"
      end
    end

    context 'will_open_at_string' do
      it 'includes date in string' do
        will_open_at_string = will_open_at_string(panel: panel)

        expect(will_open_at_string).to include time_portion(panel: panel, which_date: 'start') # include panel.start_datetime.strftime('%l:%M%P')
        expect(will_open_at_string).not_to include date_portion(panel: panel, which_date: 'start') # include "on #{panel.start_datetime.strftime('%-m/%-d/%Y')}"
      end
    end
  end

  context 'panel is not scheduled' do
    let(:panel) { create(:no_panel_dates) }

    context 'will_open_at_string' do
      it 'returns "unscheduled"' do
        expect(will_open_at_string(panel: panel)).to eql 'unscheduled'
      end
    end

    context 'will_close_at_string' do
      it 'returns "unscheduled"' do
        expect(will_close_at_string(panel: panel)).to eql 'unscheduled'
      end
    end
  end

  def time_portion(panel:, which_date:)
    open_or_close = "#{which_date}_datetime"
    panel.send(open_or_close).strftime('%l:%M%P')
  end

  def date_portion(panel:, which_date:)
    open_or_close = "#{which_date}_datetime"
    "on #{panel.send(open_or_close).strftime('%-m/%-d/%Y')}"
  end
end
