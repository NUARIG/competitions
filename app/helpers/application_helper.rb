# frozen_string_literal: true

module ApplicationHelper
  # CALLOUTS
  def foundation_alert_class_for(flash_type)
    flash_type.to_s == 'notice' ? 'success' : flash_type
  end

  def format_flash_messages(flash_content)
    begin
      case flash_content.class.name
      when 'Array'
        messages = '<p>Please review the following ' + 'error'.pluralize(flash_content.count) + ':</p>'
        messages << simple_format((array_to_html_list flash_content), {}, wrapper_tag: 'ul')
        messages
      else
        flash_content
      end.html_safe
    rescue
      'An error occurred.'
    end
  end

  def array_to_html_list(array)
    array.map { |item| "<li>#{item}</li>" }.join
  end

  # Returns the full title on a per-page basis.
  def title_tag_content(page_title: '')
    base_title = 'Competitions'
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  # Dates
  def date_mmddyyyy(date)
    date.nil? ? '' : date.strftime('%m/%d/%Y')
  end
end
