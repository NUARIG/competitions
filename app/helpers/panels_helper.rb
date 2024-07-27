module PanelsHelper
  def will_close_at_string(panel:)
    return 'unscheduled' if panel.end_datetime.blank?

    panel.end_datetime.today? ? panel.end_datetime.strftime('%l:%M%P') : panel.end_datetime.strftime('%l:%M%P on %-m/%-d/%Y')
  end

  def will_open_at_string(panel:)
    return 'unscheduled' if panel.start_datetime.blank?

    panel.start_datetime.today? ? panel.start_datetime.strftime('%l:%M%P') : panel.start_datetime.strftime('%l:%M%P on %-m/%-d/%Y')
  end

  def panel_flash_message_content(panel:)
    if panel.start_datetime.blank?
      { header: content_tag(:strong, 'This grant has not scheduled a panel.') }
    elsif panel.is_open?
      { text: content_tag(:p,
                          "This section will be available to reviewers until #{will_close_at_string(panel: panel)}.") }
    elsif panel.start_datetime > DateTime.now
      { header: content_tag(:strong, 'Panel has not yet started.'),
        text: content_tag(:p, "This section will be available to reviewers at #{will_open_at_string(panel: panel)}.") }
    else
      { header: content_tag(:strong, 'Panel has ended.'),
        text: content_tag(:p, 'This panel has ended and is no longer accessible to reviewers.') }
    end
  end
end
