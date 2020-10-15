module PanelsHelper
  def will_close_at_string(panel: )
    panel.end_datetime.today? ? panel.end_datetime.strftime("%l:%M%P") : panel.end_datetime.strftime("%l:%M%P on %-m/%-d/%Y")
  end

  def will_open_at_string(panel: )
    @panel.start_datetime.today? ? @panel.start_datetime.strftime("%l:%M%P") : @panel.start_datetime.strftime("%l:%M%P on %-m/%-d/%Y")
  end
end
