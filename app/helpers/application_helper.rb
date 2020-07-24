# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  # DEVISE ADDITIONS TO SUPPORT MULTIPLE USER TYPES.
  # def user_signed_in?
  #   saml_user_signed_in? || registered_user_signed_in?
  # end

  # def current_user
  #   current_saml_user  || current_registered_user
  end

  # def user_type?(resource, user_class)
  #   resource.class == user_class
  # end

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
    date.blank? ? '' : date.strftime('%m/%d/%Y')
  end

  def date_time_separate_lines(date)
    date.blank? ? '' : date.strftime('%m/%d/%Y<br/>%l:%M%P').html_safe
  end

  # Exports
  def prepare_excel_worksheet_name(sheet_name:)
    sheet_name.gsub(/\\/, '').gsub(/[\/*\[\]:?]/, '').truncate(31, omission: '')
  end

  # BEGIN FormBuilder
  def view_or_edit(form)
    form.available? ? "Edit" : "View"
  end

  def view_or_edit_class(form)
    form.available? ? "warning" : "secondary"
  end

  # see https://github.com/ryanb/nested_form/wiki/How-To:-Custom-nested-form-builders
  def grant_form_for(*args, &block)
    options = args.extract_options!.reverse_merge(:builder => GrantSubmissionFormBuilder)

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

  def sortable_header(column, title = nil)
    column = column.to_s
    title ||= column.titleize
    is_sorting_column = (column == sort_column)
    direction = is_sorting_column && sort_direction == 'asc' ? 'desc' : 'asc'
    url = url_for params.to_unsafe_hash.merge({:sort_column => column, :sort_direction => direction})
    content_tag(:th, title, class: is_sorting_column ? "sorting_#{sort_direction}" : 'sorting',
                onClick: "document.location.href='#{url}';".html_safe)
  end

  def form_table_row(f, attr, &field)
    render(partial: "form_table_row", locals: {f: f, attr: attr, field: field})
  end
  # /END FORM BUILDER
end
