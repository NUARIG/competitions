# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  # CALLOUTS
  def foundation_alert_class_for(flash_type)
    flash_type.to_s == 'notice' ? 'success' : flash_type
  end

  def format_flash_messages(flash_content)
    case flash_content.class.name
    when 'Array'
      messages = '<p>Please review the following ' + 'error'.pluralize(flash_content.count) + ':</p>'
      messages << simple_format((array_to_html_list flash_content), {}, wrapper_tag: 'ul')
    else
      flash_content
    end.html_safe
  rescue StandardError
    'An error occurred.'
  end

  def array_to_html_list(array)
    array.map { |item| "<li>#{item}</li>" }.join
  end

  def inline_error_notifications(object:, type: 'alert')
    if object.errors.any?
      tag.div class: "callout #{type} small" do
        "#{object.errors.full_messages.to_sentence}."
      end
    end
  end

  # Returns the full title on a per-page basis.
  def title_tag_content(page_title: '')
    base_title = COMPETITIONS_CONFIG[:application_name]
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  # Dates
  def date_mmddyyyy(date)
    date.present? ? I18n.l(date, format: :mmddyyyy) : ''
  end

  def display_datetime(datetime)
    datetime.present? ? I18n.l(datetime, format: :default) : ''
  end

  def date_time_date_only(date)
    date.present? ? I18n.l(date, format: :mmddyyyy) : ''
  end

  def date_time_separate_lines(date)
    date.present? ? time_tag(date, I18n.l(date, format: :two_lines).html_safe) : ''
  end

  def time_ago_tag(datetime:)
    time_tag(datetime, time_ago_in_words(datetime))
  end

  def readable_date(date)
    date.present? ? time_tag(date, I18n.l(date, format: :readable)) : ''
  end

  # Exports
  def prepare_excel_worksheet_name(sheet_name:)
    sheet_name.gsub(/\\/, '').gsub(%r{[/*\[\]:?]}, '').truncate(31, omission: '')
  end

  # BEGIN FormBuilder
  def view_or_edit(form)
    form.available? ? 'Edit' : 'View'
  end

  def view_or_edit_class(form)
    form.available? ? 'warning' : 'secondary'
  end

  # see https://github.com/ryanb/nested_form/wiki/How-To:-Custom-nested-form-builders
  def grant_form_for(*args, &block)
    options = args.extract_options!.reverse_merge(builder: GrantSubmissionFormBuilder)

    form_for(*(args << options)) do |f|
      f.read_only = true if user_form_read_only?
      capture(f, &block).to_s << after_nested_form_callbacks
    end
  end

  def user_form_read_only?
    # TODO: Update/Create Policy for admins, etc.
    #       Using multiple arguments with Pundit
    @user # && !Pundit.policy(current_user, @user).update?
  end

  def form_table_row(f, attr, &field)
    render(partial: 'form_table_row', locals: { f: f, attr: attr, field: field })
  end
  # /END FORM BUILDER
end
